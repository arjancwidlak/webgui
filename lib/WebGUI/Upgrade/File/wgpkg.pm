package WebGUI::Upgrade::File::wgpkg;
use 5.010;
use strict;
use warnings;

use WebGUI::Asset;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::VersionTag;
use File::Spec;

sub run {
    my $class = shift;
    my ($configFile, $version, $file, $quiet) = @_;

    my $session = WebGUI::Session->open($configFile);
    $session->user({user => 3});

    # Make a storage location for the package
    my $storage = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    (undef, undef, my $shortname) = File::Spec->splitpath($file);
    $shortname =~ s/\.[^.]*$//;

    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name => "Upgrade to $version - $shortname"});

    # Import the package into the import node
    my $package = eval {
        WebGUI::Asset->getImportNode($session)->importPackage( $storage );
    };

    $storage->delete;

    if ($package eq 'corrupt') {
        die "Corrupt package found in $file.\n";
    }
    if ($@ || !defined $package) {
        die "Error during package import on $file: $@\n";
    }

    # Turn off the package flag, and set the default flag for templates added
    my $assetIds = $package->getLineage( ['self','descendants'] );
    for my $assetId ( @{ $assetIds } ) {
        my $asset = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( !$asset ) {
            print "Couldn't instantiate asset with ID '$assetId'. Please check package '$file' for corruption.\n";
            next;
        }
        my $properties = { isPackage => 0 };
        if ($asset->isa('WebGUI::Asset::Template')) {
            $properties->{isDefault} = 1;
        }
        $asset->update( $properties );
    }

    $versionTag->commit;
    $session->var->end;
    $session->close;

    return 1;
}

1;

