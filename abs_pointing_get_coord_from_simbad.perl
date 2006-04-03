#!/usr/local/bin/perl

#################################################################################
#										#
#	abs_pointing_get_coord_from_simbad.perl: extract coordinates 		#
#				informaiton from SIMBAD	database.		#
#										#
#	author:	t. isobe (tisobe@cfa.harvard.edu)				#
#										#
#	last update: 03/31/2006							#
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
$data_dir = $list[3];

#
#--- copy Query_mta.pm to working directory
#--- this will be used in simbad_query.perl
#

system("cp $data_dir/Abs_pointing/Query_mta.pm .");

#
#--- set email user name who will get email when coordinates are not obtained
#

$user = $ARGV[0];
chomp $user;

#
#--- read target names etc
#

open(FH, './check_coord');
@targets = ();
@obsid   = ();
@inst    = ();
@grat    = ();
$total   = 0;
while(<FH>){
	chomp $_;
	@atemp = split(/\t+/, $_);
	push(@targets, $atemp[0]);
	push(@obsid,   $atemp[1]);
	push(@inst,    $atemp[2]);
	push(@grat,    $atemp[3]);
	$total++;
}
close(FH);

@target_list = ();
open(FH, './simbad_list');
while(<FH>){
	chomp $_;
	push(@target_list, $_);
}
close(FH);

@results    = ();
@check_list = ();

foreach $target (@target_list){
#
#--- print a target name on a file so that the main script can read it
#
	open(OUT2, ">tag_name");
	print OUT2 "$target\n";
	close(OUT2);
#
#--- simbad_query.perl actually goes to SIBAD site and retrieves coordinate
#--- information. it must be run with /usr/local/bin/perl5.8.6.
#
	system("/usr/local/bin/perl5.8.6 $bin_dir/abs_pointing_simbad_query.perl");
	$sim_data = `cat simbad_out`;
	@ctemp = split(/\t+/, $sim_data);
#
#--- default settings for coordinates
#
	$ra    = '99:99:99.999';
	$dec   = '99:99:99.999';
	$pmra  = '0.0';
	$pmdec = '0.0';
	if($ctemp[0] =~ /\d/ && $ctemp[1] =~ /\d/){
		$ra = $ctemp[0];
		$dec = $ctemp[1];
		if($ctemp[2] =~ /\d/ && $ctemp[3] =~ /\d/){
			$pmra  = $ctemp[2];
			$pmdec = $ctemp[3];
			chomp $pmra;
			chomp $pmdec;
		}
	}else{
#
#--- if simbad failed to give coordinate information, keep the target name
#--- in check_list.
#
		push(@check_list, $target);
	}

	system("rm simbad_out");
#
#--- adjust target name length so that when it is printed, looks prittier.
#
	@atemp = split(//, $target);
	$tcnt = 0;
	foreach(@atemp){
		$tcnt++;
	}
	if($tcnt < 8){
        	$line = "$target\t\t$ra\t$dec\t$pmra\t$pmdec";
	}else{
        	$line = "$target\t$ra\t$dec\t$pmra\t$pmdec";
	}
	push(@results, $line);
}
#
#--- remove duplicated lines
#
$first = shift(@results);
@new   = ($first);
OUTER:
foreach $ent (@results){
	foreach $comp (@new){
		if($ent eq $comp){
			next OUTER;
		}
	}
	push(@new, $ent);
}

@results = @new;
#
#---- put the newly found coordinate values to coord_list
#
open(OUT, ">>$house_keeping/coord_list");
foreach $ent (@new){
	print OUT "$ent\n";
}
close(OUT);

#
#---- print checked coordinate values in know_coord list
#

open(OUT, '>>./known_coord');
OUTER:
for($i = 0; $i < $total; $i++){
	foreach $ent (@results){
		if($ent =~ /$targets[$i]/i){
			print OUT "$obsid[$i]\t$inst[$i]\t$grat[$i]\t$ent\n";
			next OUTER;
		}
	}
}
close(OUT);
#
#--- print out targets which we could not identify the coordinates
#
open(OUT, ">$house_keeping/unknown_coordinate");
$chk = 0;
OUTER:
for($i = 0; $i < $total; $i++){
	foreach $ent (@check_list){
		if($ent eq $targets[$i]){
			print OUT "$obsid[$i]\t$inst[$i]\t$grat[$i]\t$ent\n";
			$chk++;
			next OUTER;
		}
	}
}

#
#--- sending email to $usere so that he can check unchecked target manually
#
if($chk > 0){
	system("cat ./unknown_coordniate |mailx -s \"Subject: Aiming Point Monitoring: Unchecked coodinates\n\" -r  $user\@head-cfa.harvard.edu   $user\@head-cfa.harvard.edu");

	system("cat ./unknown_coordniate >> $house_keeping/unknown_coordiate");
}
system("rm ./unknown_coordiate Query_mta.pm");

