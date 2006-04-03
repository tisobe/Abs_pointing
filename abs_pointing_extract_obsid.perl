#!/usr/bin/perl

#########################################################################
#									#
#	abs_pointing_extract_obsid.perl: this script updates obsid_list	#
#			    which lists already processed objects	#
#	    use this after comp_second_time.perl			#
#									#
#	author: t. isobe (tisobe@cfa.harvard.edu)			#
#	last update:  Mar 22 , 2006					#
#		modified to fit a new directory system			#
#									#
#########################################################################

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

