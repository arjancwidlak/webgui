package WebGUI::Operation::Statistics;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewStatistics);

#-------------------------------------------------------------------
sub www_viewStatistics {
        my ($output, $data);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=12"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
                $output .= '<h1>'.WebGUI::International::get(144).'</h1>';
		$output .= '<table>';
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(145).'</td><td class="tableData">'.$WebGUI::VERSION.'</td></tr>';
		($data) = WebGUI::SQL->quickArray("select count(*) from session",$session{dbh});
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(146).'</td><td class="tableData">'.$data.'</td></tr>';
		($data) = WebGUI::SQL->quickArray("select count(*)+1 from page where parentId>25",$session{dbh});
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(147).'</td><td class="tableData">'.$data.'</td></tr>';
		($data) = WebGUI::SQL->quickArray("select count(*) from page where pageId>25 or pageId=0",$session{dbh});
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(148).'</td><td class="tableData">'.$data.'</td></tr>';
		($data) = WebGUI::SQL->quickArray("select count(*) from users where userId>25",$session{dbh});
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(149).'</td><td class="tableData">'.$data.'</td></tr>';
		($data) = WebGUI::SQL->quickArray("select count(*) from groups where groupId>25",$session{dbh});
		$output .= '<tr><td class="tableHeader">'.WebGUI::International::get(89).'</td><td class="tableData">'.$data.'</td></tr>';
		$output .= '</table>';
        } else {
                $output = WebGUI::Privilege::adminOnly();
        }
        return $output;
}



1;

