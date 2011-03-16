#!/usr/bin/perl

#########################################################################
#									#
#	abs_pointing_extract_obsid.perl: this script updates obsid_list	#
#			    which lists already processed objects	#
#	    use this after comp_second_time.perl			#
#									#
#	author: t. isobe (tisobe@cfa.harvard.edu)			#
#	last update:  Mar 16 , 2011					#
#		modified to fit a new directory system			#
#									#
#########################################################################

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


###################################################################

open(FH, "$house_keeping/obsid_list");
@obsid_list = ();
while(<FH>){
	chomp $_;
	push(@obsid_list, $_);
}
close(FH);

open(FH, "./known_coord");
while(<FH>){
	chomp $_;
	@atemp = split(/\s+/, $_);
	push(@obsid_list, $atemp[0]);
}
close(FH);

$first = shift(@obsid_list);
@new = ($first);
OUTER:
foreach $ent (@obsid_list){
	foreach $comp (@new){
		if($ent == $comp){	
			next OUTER;
		}
	}
	push(@new, $ent);
}

@obsid_list = sort{$a<=>$b} @new;

open(OUT, ">$house_keeping/obsid_list");
foreach $ent (@obsid_list){
	print OUT "$ent\n";
}
close(OUT);

