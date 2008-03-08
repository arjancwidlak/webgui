package WebGUI::Shop::Ship;

use strict;

use Class::InsideOut qw{ :std };
use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Shop::Admin;
use WebGUI::Shop::ShipDriver;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Shop::Ship

=head1 DESCRIPTION

This is the master class to manage ship drivers.

=head1 SYNOPSIS

 use WebGUI::Shop::Ship;

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;


#-------------------------------------------------------------------

=head2 addShipper ( $class, $options )

The interface method for creating new, configured instances of ShipDriver.  If the ShipperDriver throws an exception,  it is propagated
back up to the top.

=head4 $class

The class of the new ShipDriver object to create.

=head4 $options

A list of properties to assign to this ShipperDriver.  See C<definition> for details.

=cut

sub addShipper {
    my $self   = shift;
    my $requestedClass = shift;
    my $options = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a class to create an object})
        unless defined $requestedClass;
    WebGUI::Error::InvalidParam->throw(error => qq{The requested class $requestedClass is not enabled in your WebGUI configuration file}, param => $requestedClass)
        unless isIn($requestedClass, (keys %{$self->getDrivers}) );
    WebGUI::Error::InvalidParam->throw(error => q{You must pass a hashref of options to create a new ShipDriver object})
        unless defined($options) and ref $options eq 'HASH' and scalar keys %{ $options };
    my $driver = eval { WebGUI::Pluggable::instanciate($requestedClass, 'create', [ $self->session, $options ]) };
    return $driver;
}

#-------------------------------------------------------------------

=head2 getDrivers ( )

This subroutine returns a hash reference of available shipping driver classes as keys with their human readable names as values, read from the WebGUI config file in the shippingDrivers directive.

=cut

sub getDrivers {
    my $self      = shift;
    my %drivers = ();
    foreach my $class (@{$self->session->config->get('shippingDrivers')}) {
        $drivers{$class} = eval { WebGUI::Pluggable::instanciate($class, 'getName', [ $self->session ])};
    }
    return \%drivers;
}

#-------------------------------------------------------------------

=head2 getOptions ( $cart )

Returns a list of options for the user to ship, along with the cost of using each one.  It is a hash of hashrefs,
with the key of the primary hash being the shipperId of the driver, and sub keys of label and price.

=head3 $cart

A WebGUI::Shop::Cart object.  A WebGUI::Error::InvalidParam exception will be thrown if it doesn't get one.

=head3

=cut

sub getOptions {
    my ($self, $cart) = @_;
    WebGUI::Error::InvalidParam->throw(error => q{Need a cart.}) unless defined $cart and $cart->isa("WebGUI::Shop::Cart");
    my $session = $cart->session; 
    my %options = ();
    foreach my $shipper (@{$self->getShippers()}) {
        $options{$shipper->getId} = {
            label => $shipper->get("label"),
            price => $shipper->calculate($cart),
            };    
    }
    return \%options;
}

#-------------------------------------------------------------------

=head2 getShipper ( )

Looks up an existing ShipperDriver in the db by shipperId and returns
that object.  If the ShipperDriver throws an exception,  it is propagated
back up to the top.

=head3 id

The id of the shipper to instanciate.

=cut

sub getShipper {
    my ($self, $shipperId) = @_;
    my $session = $self->session;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a shipperId})
        unless defined $shipperId;
    my $requestedClass = $session->db->quickScalar('select className from shipper where shipperId=?',[$shipperId]);
    WebGUI::Error::ObjectNotFound->throw(error => q{shipperId not found in db}, id => $shipperId)
        unless $requestedClass;
    my $driver = eval { WebGUI::Pluggable::instanciate($requestedClass, 'new', [ $session, $shipperId ]) };
    return $driver;
}

#-------------------------------------------------------------------

=head2 getShippers ( )

Returns an array ref of all shipping objects in the db.

=head3

=cut

sub getShippers {
    my $self     = shift;
    my @drivers = ();
    my $sth = $self->session->db->prepare('select shipperId from shipper');
    $sth->execute();
    while (my $driver = $sth->hashRef()) {
        push @drivers, $self->getShipper($driver->{shipperId});
    }
    $sth->finish;
    return \@drivers;
}

#-------------------------------------------------------------------

=head2 new ( $session )

Constructor.

=head3 $session

A WebGUI::Session object.

=cut

sub new {
    my $class     = shift;
    my $session   = shift;
    WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error => q{Must provide a session variable}) unless ref $session eq 'WebGUI::Session';
    my $self = register $class;
    my $id        = id $self;
    $session{ $id }   = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 session () 

Returns a reference to the current session.

=cut

#-------------------------------------------------------------------

=head2 www_addDriver ()

=cut

sub www_addDriver {
    my $self = shift;
    my $form = $self->session->form;
    WebGUI::Error::InvalidParam->throw(error => q{must have a form var called className with a driver class name }) if ($form->get("className") eq "");
    my $shipper = $self->addShipper($form->get("className"), { $form->get("className")->getName($self->session), enabled=>0});
    return $shipper->www_edit;
}

#-------------------------------------------------------------------

=head2 www_do ( )

Let's ship drivers do method calls. Requires a driver param in the post form vars which contains the id of the driver to load.

=cut

sub www_do {
    my ($self) = @_;
    my $form = $self->session->form;
    WebGUI::Error::InvalidParam->throw(error => q{must have a form var called driver with a driver id }) if ($form->get("driver") eq "");
    WebGUI::Error::InvalidParam->throw(error => q{must have a form var called do with a method name in the driver }) if ($form->get("do") eq "");
    my $driver = $self->getShipper($form->get("driver"));
    my $output = undef;
    my $method = "www_". ( $form->get("do"));
    if ($driver->can($method)) {
        $output = $driver->$method();
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_manage ( )

The main management screen for shippers.

=cut

sub www_manage {
    my ($self) = @_;
    my $session = $self->session;
    return $session->privilege->adminOnly() unless ($session->user->isInGroup("3"));
    my $admin = WebGUI::Shop::Admin->new($session);
    my $i18n = WebGUI::International->new($session, "Shop");
    my $output = WebGUI::Form::formHeader($session)
        .WebGUI::Form::hidden($session, {name=>"shop", value=>"ship"})
        .WebGUI::Form::hidden($session, {name=>"method", value=>"addDriver"})
        .WebGUI::Form::selectBox($session, {name=>"className", options=>$self->getDrivers})
        .WebGUI::Form::submit($session, {value=>$i18n->get("add shipper")})
        .WebGUI::Form::formFooter($session);
    foreach my $shipper (@{$self->getShippers}) {
        
    }
    my $console = $admin->getAdminConsole;
    return $console->render($output, $i18n->get("shipping methods"));
}

1;
