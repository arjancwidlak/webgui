package WebGUI::Paginator;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::URL;

=head1 NAME

Package WebGUI::Paginator

=head1 DESCRIPTION

Package that paginates rows of arbitrary data for display on the web.

=head1 SYNOPSIS

 use WebGUI::Paginator;
 $p = WebGUI::Paginator->new("/index.pl/page_name?this=that",\@row);
 $p->setDataByQuery($sql);

 $html = $p->getBar;
 $html = $p->getBarAdvanced;
 $html = $p->getBarSimple;
 $html = $p->getBarTraditional;
 $html = $p->getFirstPageLink;
 $html = $p->getLastPageLink;
 $html = $p->getNextPageLink;
 $integer = $p->getNumberOfPages;
 $html = $p->getPage;
 $arrayRef = $p->getPageData;
 $integer = $p->getPageNumber;
 $html = $p->getPageLinks;
 $html = $p->getPreviousPageLink;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 getBar ( [ pageNumber ] )

Returns the pagination bar including First, Previous, Next, and last links. If there's only one page, nothing is returned.

=over

=item pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=back

=cut

sub getBar {
        my ($output);
        if ($_[0]->getNumberOfPages > 1) {
                $output = '<div class="pagination">';
                $output .= $_[0]->getFirstPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getPreviousPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getNextPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getLastPageLink($_[1]);
                $output .= '</div>';
                return $output;
        } else {
                return "";
        }
}


#-------------------------------------------------------------------

=head2 getBarAdvanced ( [ pageNumber ] )

Returns the pagination bar including First, Previous, Page Numbers, Next, and Last links. If there's only one page, nothing is returned.

=over

=item pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=back

=cut

sub getBarAdvanced {
        my ($output);
        if ($_[0]->getNumberOfPages > 1) {
                $output = '<div class="pagination">';
                $output .= $_[0]->getFirstPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getPreviousPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getPageLinks($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getNextPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getLastPageLink($_[1]);
                $output .= '</div>';
                return $output;
        } else {
                return "";
        }
}


#-------------------------------------------------------------------

=head2 getBarSimple ( [ pageNumber ] )

Returns the pagination bar including only Previous and Next links. If there's only one page, nothing is returned.

=over

=item pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=back

=cut 

sub getBarSimple {
	my ($output);
	if ($_[0]->getNumberOfPages > 1) {
		$output = '<div class="pagination">';
		$output .= $_[0]->getPreviousPageLink($_[1]);
		$output .= ' &middot; ';
		$output .= $_[0]->getNextPageLink($_[1]);
		$output .= '</div>';
		return $output;
	} else {
		return "";
	}
}


#-------------------------------------------------------------------

=head2 getBarTraditional ( [ pageNumber ] )

Returns the pagination bar including Previous, Page Numbers, and Next links. If there's only one page, nothing is returned.

=over

=item pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=back

=cut

sub getBarTraditional {
        my ($output);
        if ($_[0]->getNumberOfPages > 1) {
                $output = '<div class="pagination">';
                $output .= $_[0]->getPreviousPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getPageLinks($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getNextPageLink($_[1]);
                $output .= '</div>';
                return $output;
        } else {
                return "";
        }
}


#-------------------------------------------------------------------

=head2 getFirstPageLink ( [ pageNumber ] )

Returns a link to the first page's data.

=over

=item pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=back

=cut

sub getFirstPageLink {
        my ($text, $pn);
	$pn = $_[1] || $_[0]->getPageNumber;
        $text = '|&lt;'.WebGUI::International::get(404);
        if ($pn > 1) {
                return '<a href="'.
			WebGUI::URL::append($_[0]->{_url},($_[0]->{_formVar}.'=1'))
			.'">'.$text.'</a>';
        } else {
                return $text;
        }
}


#-------------------------------------------------------------------

=head2 getLastPageLink ( [ pageNumber ] )

Returns a link to the last page's data.

=over

=item pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=back

=cut

sub getLastPageLink {
        my ($text, $pn);
	$pn = $_[1] || $_[0]->getPageNumber;
        $text = WebGUI::International::get(405).'&gt;|';
        if ($pn != $_[0]->getNumberOfPages) {
                return '<a href="'.
			WebGUI::URL::append($_[0]->{_url},($_[0]->{_formVar}.'='.$_[0]->getNumberOfPages))
			.'">'.$text.'</a>';
        } else {
                return $text;
        }
}


#-------------------------------------------------------------------

=head2 getNextPageLink ( [ pageNumber ] )

Returns a link to the next page's data.

=over

=item pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=back

=cut

sub getNextPageLink {
        my ($text, $pn);
	$pn = $_[1] || $_[0]->getPageNumber;
        $text = WebGUI::International::get(92).'&raquo;';
        if ($pn < $_[0]->getNumberOfPages) {
                return '<a href="'.WebGUI::URL::append($_[0]->{_url},($_[0]->{_formVar}.'='.($pn+1))).'">'.$text.'</a>';
        } else {
                return $text;
        }
}


#-------------------------------------------------------------------

=head2 getNumberOfPages ( )

Returns the number of pages in this paginator.

=cut

sub getNumberOfPages {
	my $pageCount = int(($#{$_[0]->{_rowRef}}+1)/$_[0]->{_rpp});
	$pageCount++ unless (($#{$_[0]->{_rowRef}}+1)%$_[0]->{_rpp} == 0);
	return $pageCount;
}


#-------------------------------------------------------------------

=head2 getPage ( [ pageNumber ] )

Returns the data from the page specified as a string. 

NOTE: This is really only useful if you passed in an array reference of strings when you created this object.

=over

=item pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=back

=cut

sub getPage {
	return join("",@{$_[0]->getPageData($_[1])});
}


#-------------------------------------------------------------------

=head2 getPageData ( [ pageNumber ] )

Returns the data from the page specified as an array reference.

=over

=item pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=back

=cut

sub getPageData {
	my ($i, @pageRows, $allRows, $pageCount, $pageNumber, $rowsPerPage, $pageStartRow, $pageEndRow);
        $pageNumber = $_[1] || $_[0]->getPageNumber;
        $pageCount = $_[0]->getNumberOfPages;
        return [] if ($pageNumber > $pageCount);
        $rowsPerPage = $_[0]->{_rpp};
        $pageStartRow = ($pageNumber*$rowsPerPage)-$rowsPerPage;
        $pageEndRow = $pageNumber*$rowsPerPage;
	$allRows = $_[0]->{_rowRef};
        for ($i=$pageStartRow; $i<$pageEndRow; $i++) {
		$pageRows[$i-$pageStartRow] = $allRows->[$i] if ($i <= $#{$_[0]->{_rowRef}});
        }
	return \@pageRows;
}

#-------------------------------------------------------------------

=head2 getPageNumber ( )

Returns the current page number. If no page number can be found then it returns 1.

=cut

sub getPageNumber {
        return $_[0]->{_pn};
}

#-------------------------------------------------------------------

=head2 getPageLinks ( [ pageNumber ] )

Returns links to all pages in this paginator.

=over

=item pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=back

=cut

sub getPageLinks {
        my ($i, $output, $pn);
	$pn = $_[1] || $_[0]->getPageNumber;
	for ($i=0; $i<$_[0]->getNumberOfPages; $i++) {
		if ($i+1 == $pn) {
			$output .= ' '.($i+1).' ';
		} else {
			$output .= ' <a href="'.
				WebGUI::URL::append($_[0]->{_url},($_[0]->{_formVar}.'='.($i+1)))
				.'">'.($i+1).'</a> ';
		}
	}
	return $output;
}


#-------------------------------------------------------------------

=head2 getPreviousPageLink ( [ pageNumber ] )

Returns a link to the previous page's data. 

=over

=item pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=back

=cut

sub getPreviousPageLink {
	my ($text, $pn);
	$pn = $_[1] || $_[0]->getPageNumber;
	$text = '&laquo;'.WebGUI::International::get(91);
	if ($pn > 1) {
		return '<a href="'.WebGUI::URL::append($_[0]->{_url},($_[0]->{_formVar}.'='.($pn-1))).'">'.$text.'</a>';
        } else {
        	return $text;
        }
}


#-------------------------------------------------------------------

=head2 new ( currentURL, rowArrayRef [, paginateAfter, pageNumber, formVar ] )

Constructor.

=over

=item currentURL

The URL of the current page including attributes. The page number will be appended to this in all links generated by the paginator.

=item rowArrayRef

An array reference to all the rows of data for this page.

=item paginateAfter

The number of rows to display per page. If left blank it defaults to 50.

=item pageNumber 

By default the paginator uses a form variable of "pn" to determine the page number. If you wish it to use some other variable, then specify the page number here.

=item formVar

Specify the form variable the paginator should use in it's links.  Defaults to "pn".

=back

=cut

sub new {
        my ($class, $currentURL, $rowsPerPage, $rowRef, $formVar, $pageRef, $pn);
	$class = $_[0];
	$currentURL = $_[1];
	$rowRef = $_[2];
	$rowsPerPage = $_[3] || 25;
	$formVar = $_[5] || "pn";
	$pn = $_[4] || $session{form}{$formVar} || 1;
        bless {_url => $currentURL, _rpp => $rowsPerPage, _rowRef => $rowRef, _formVar => $formVar, _pn => $pn}, $class;
}

#-------------------------------------------------------------------

=head2 setDataByQuery ( query [, dbh ] )

Retrieves a data set from a database and replaces whatever data set was passed in through the constructor.

NOTE: This retrieves only the current page's data for efficiency.

=over

=item query

An SQL query that will retrieve a data set.

=item dbh

A DBI-style database handler. Defaults to the WebGUI site handler.

=back

=cut

sub setDataByQuery {
	my ($sth, $pageCount, $rowCount, $dbh, $sql, $self, @row, $data);
	($self, $sql, $dbh) = @_;
	$dbh |= $session{dbh};
	$sth = WebGUI::SQL->read($sql);
	$pageCount = 1;
	while ($data = $sth->hashRef) {
		$rowCount++;
		if ($rowCount/$self->{_rpp} > $pageCount) {	
			$pageCount++;
		}
		if ($pageCount == $self->getPageNumber) {
			push(@row,$data);	
		} else {
			push(@row,{});
		}
	}
	$sth->finish;
	$self->{_rowRef} = \@row;
}

1;


