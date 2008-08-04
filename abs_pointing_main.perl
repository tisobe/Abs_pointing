#!/usr/bin/perl

#################################################################################
#										#
#	abs_pointing_main.perl: a control perl script for abs_pointing 		#
#										#
#	author: t. isobe (tisobe@cfa.harvard.edu)				#
#										#
#	last update: Aug 04, 2008						#
#										#
#################################################################################

###################################################################
#
#---- setting directories
#
$bin_dir       = '/data/mta/MTA/bin/';
$web_dir       = '/data/mta/www/mta_aiming/';
$house_keeping = '/data/mta/www/mta_aiming/house_keeping/';
$data_dir      = '/data/mta/MTA/data/';

#
#---- and others
#
$user          = 'isobe';

###################################################################

#
#--- create a directory file so that other scripts can read it
#

open(OUT, '>./dir_list');
print OUT "$bin_dir\n";
print OUT "$web_dir\n";
print OUT "$house_keeping\n";
print OUT "$data_dir\n";
close(OUT);

system("/proj/DS.ots/perl-5.10.0.SunOS5.8/bin/perl  $bin_dir/abs_pointing_find_candidate.perl");
system("perl $bin_dir/abs_pointing_comp_entry.perl");
system("perl $bin_dir/abs_pointing_get_coord_from_simbad.perl $user");
####system("perl $bin_dir/abs_pointing_comp_second_time.perl");
system("perl $bin_dir/abs_pointing_extract_obsid.perl");
system("perl $bin_dir/abs_pointing_compute_pos_diff.perl");
system("perl $bin_dir/abs_pointing_acis_plot.perl");
system("perl $bin_dir/abs_pointing_hrci_plot.perl");
system("perl $bin_dir/abs_pointing_hrcs_plot.perl");
system("perl $bin_dir/abs_pointing_print_html.perl");


system("rm candidate_list check_coord dir_list known_coord new_obsid_list simbad_list");
