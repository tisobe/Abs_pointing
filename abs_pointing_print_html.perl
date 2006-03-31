#!/usr/bin/perl

#################################################################################
#										#
#	print_html.perl: print a html page for coordinate accuracy web		#
#										#
#	Author:	Takashi Isobe (tisobe@cfa.harvard.edu)				#
#										#
#	Sep 20, 2000:	First version						#
#	Mar 22, 2006:	a new directory system					#
#										#
#################################################################################

#
#--- read directory list
#
open(FH, './dir_list');
@list = ();
while(<FH>){
        chomp $_;
        push(@list, $_);
}
close(FH);
$bin_dir = $list[0];
$web_dir = $list[1];
$house_keeping = $list[2];
$data_dir= $list[3];

#######	checking today's date #######

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);

if($uyear < 1900) {
        $uyear = 1900 + $uyear;
}
$month = $umon + 1;

if ($uyear == 1999) {
        $dom = $uyday - 202;
}elsif($uyear >= 2000){
        $dom = $uyday + 163 + 365*($uyear - 2000);
        if($uyear > 2000) {
                $dom++;
        }
        if($uyear > 2004) {
                $dom++;
        }
        if($uyear > 2008) {
                $dom++;
        }
        if($uyear > 20012) {
                $dom++;
        }
}


###### creating a main page #######

open(OUT, ">$web_dir/aiming_page.html");

print OUT '<HTML>';

print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000", background="./stars.jpg">',"\n";

print OUT '<title> Celestial Location Monitoring</title>',"\n";

print OUT '<CENTER><H2>ACIS-S and HRC Celestial Location Monitoring </H2> </CENTER>',"\n";

#print OUT '<CENTER><H1>Updated ';
#print OUT "$uyear-$month-$umday  ";
#print OUT "\n";
#print OUT "<br>";
#print OUT "DAY OF YEAR: $uyday ";
#print OUT "\n";
#print OUT "<br>";
#print OUT "DAY OF MISSION: $dom ";
#print OUT '</H1></CENTER>';
#print OUT "\n";
print OUT '<P>';
print OUT "\n";
print OUT '<HR>';
print OUT '<H3> PLOTS </H3>',"\n";
print OUT '<P>',"\n";
print OUT 'The following plots are the differences between coordinates obtained';
print OUT ' from Chandra observations and those obtained from existing catalogs';
print OUT ' vs time in day of mission.',"\n";
print OUT '</P>',"\n";
print OUT '<P>',"\n";
print OUT 'The following steps are taken to generate these plots',"\n";
print OUT '</P>',"\n";
print OUT '<P>',"\n";
print OUT '<ul>',"\n";
print OUT '<li> All observations with grating are selected from a recent observation list';
print OUT 'None grating observations with known point sources (e.g., previously observed objects)';
print OUT 'are also added to the list.';
print OUT '<br>',"\n";
print OUT '<li> Find coordinates for each observation from SIMBAD. If the coordinates information is ';
print OUT 'given at three decimal accuracy, we use the observation. Otherwise';
print OUT ' it is dropped from the further process. ';
print OUT 'These coordinates are converted into detector coordinates';
print OUT '<br>',"\n";
print OUT '<li> Using a cell detect function, find source positions in detector coordinates.';
print OUT '<br>',"\n";
print OUT '<li> Assuming the brightest object is the targeted source (this is true most of';
print OUT ' the time, because all observations are grating observations),';
print OUT ' compare those to the coordinates from the SIMBAD';
print OUT '<br>',"\n";
print OUT '<li> Convert the differences into arc sec, and plot the results';
print OUT '</ul>',"\n";
print OUT '</P>',"\n";


print OUT '<A HREF=./acis_s_plot.html> ACIS S Plot</A>',"\n";
print OUT '<br>',"\n";
print OUT '<A HREF=./hrc_s_plot.html> HRC S Plot</A>',"\n";
print OUT '<br>',"\n";
print OUT '<A HREF=./hrc_i_plot.html> HRC I Plot</A>',"\n";
print OUT '<br>',"\n";

print OUT '<hr>',"\n";

print OUT '<H3> DATA Plotted (ASCII format) </H3>',"\n";
print OUT '<A HREF=./Data/acis_s_data>ACIS S Data</A>',"\n";
print OUT '<br>',"\n";
print OUT '<A HREF=./Data/hrc_s_data>HRC S Data</A>',"\n";
print OUT '<br>',"\n";
print OUT '<A HREF=./Data/hrc_i_data>HRC I Data</A>',"\n";
print OUT '<br>',"\n";

print OUT '<hr>',"\n";
print OUT '<A HREF=http://icxc.harvard.edu/cal/drift/drift4.html>';
print OUT 'Maxim Markevitch (maxim@head-cfa.harvard.edu) Study (password required)';
print OUT '</A>';
print OUT '<br>',"\n";
print OUT '<A HREF=http://asc.harvard.edu/mta/sot.html>Back to SOT page</A>';
print OUT '<br><br>',"\n";
print OUT "Last Update: $uyear-$month-$umday\n";
close(OUT);

####### printing an acis plot html page   ########

open(OUT,">$web_dir/acis_s_plot.html");

print OUT '<HTML>';

print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000">',"\n";

print OUT '<title> ACIS-S Aiming Plot</title>',"\n";

print OUT '<CENTER><H2>ACIS-S Cooridnate Accuracy</H2> </CENTER>',"\n";

print OUT "\n";
print OUT '<P>';
print OUT "\n";

print OUT '<HR>',"\n";

print OUT '<center>',"\n";
print OUT '<IMG SRC="./Fig_save/acis_point_err.gif" width=800 height=800>',"\n";
print OUT '</center>',"\n";
print OUT '<br><br>',"\n";
print OUT '<a href=./aiming_page.html>Back to Top page</a>',"\n";
print OUT '<br><br>',"\n";
print OUT "Last Update: $uyear-$month-$umday\n";


close(OUT);


###### printing a hrc s plot html page   ########

open(OUT,">$web_dir/hrc_s_plot.html");

print OUT '<HTML>';

print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000">',"\n";

print OUT '<title> HRC-S Aiming Plot</title>',"\n";

print OUT '<CENTER><H2>HRC-S Cooridnate Accuracy</H2> </CENTER>',"\n";

print OUT "\n";
print OUT '<P>';
print OUT "\n";

print OUT '<HR>',"\n";

print OUT '<center>',"\n";
print OUT '<IMG SRC="./Fig_save/hrc_s_point_err.gif" width=800 height=800>',"\n";
print OUT '</center>',"\n";
print OUT '<br><br>',"\n";
print OUT '<a href=./aiming_page.html>Back to Top page</a>',"\n";
print OUT '<br><br>',"\n";
print OUT "Last Update: $uyear-$month-$umday\n";

close(OUT);



##### printing a hrc i plot html page    #########

open(OUT,">$web_dir/hrc_i_plot.html");

print OUT '<HTML>';

print OUT '<BODY TEXT="#FFFFFF" BGCOLOR="#000000" LINK="#00CCFF" VLINK="#B6FFFF" ALINK="#FF0000">',"\n";

print OUT '<title> HRC-I Aiming Plot</title>',"\n";

print OUT '<CENTER><H2>HRC-I Cooridnate Accuracy</H2> </CENTER>',"\n";

print OUT "\n";
print OUT '<P>';
print OUT "\n";

print OUT '<HR>',"\n";

print OUT '<center>',"\n";
print OUT '<IMG SRC="./Fig_save/hrc_i_point_err.gif" width=800 height=800>',"\n";
print OUT '</center>',"\n";
print OUT '<br><br>',"\n";
print OUT '<a href=./aiming_page.html>Back to Top page</a>',"\n";
print OUT '<br><br>',"\n";
print OUT "Last Update: $uyear-$month-$umday\n";


close(OUT);


