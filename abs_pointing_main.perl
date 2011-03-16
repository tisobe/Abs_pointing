#!/usr/bin/perl

#################################################################################
#										#
#	abs_pointing_main.perl: a control perl script for abs_pointing 		#
#										#
#	author: t. isobe (tisobe@cfa.harvard.edu)				#
#										#
#	last update: Mar 16, 2011						#
#										#
#################################################################################

###################################################################
#
#---- setting directories
#

open(FH, "/data/mta/Script/ALIGNMENT/Abs_pointing/house_keeping/dir_list");
@atemp = ();
while(<FH>){
        chomp $_;
        push(@atemp, $_);
}
close(FH);

$bin_dir       = $atemp[0];
$bdata_dir     = $atemp[1];
$web_dir       = $atemp[2];
$data_dir      = $atemp[3];
$house_keeping = $atemp[4];

#
#---- and others
#
open(FH, "$bdata_dir/.dare");
@inline =<FH>;
close(FH);
$dare = $inline[0];
$dare =~ s/\s+//;

###################################################################


system("/soft/ascds/DS.release/ots/bin/perl  $bin_dir/abs_pointing_find_candidate.perl");

system("/opt/local/bin/perl $bin_dir/abs_pointing_comp_entry.perl");
system("/opt/local/bin/perl $bin_dir/abs_pointing_get_coord_from_simbad.perl $dare");
system("/opt/local/bin/perl $bin_dir/abs_pointing_extract_obsid.perl");
system("/opt/local/bin/perl $bin_dir/abs_pointing_compute_pos_diff.perl");
system("/opt/local/bin/perl $bin_dir/abs_pointing_acis_plot.perl");
system("/opt/local/bin/perl $bin_dir/abs_pointing_hrci_plot.perl");
system("/opt/local/bin/perl $bin_dir/abs_pointing_hrcs_plot.perl");
system("/opt/local/bin/perl $bin_dir/abs_pointing_print_html.perl");


system("rm candidate_list check_coord dir_list known_coord new_obsid_list simbad_list");
