#!/usr/bin/perl

#################################################################################
#										#
#	abs_pointing_compute_pos_diff.perl: read a list of the point source and	#
#			      find a location of the source, and find difference#
#			      between the position and those from SYMBAD	#
#										#
#	author: T. Isobe (tisobue@cfa.harvard.edu)				#
#	last update: Mar 30 2006						#
#                 modified to fit a new directory system			#
#		  added input data (known_coord) check				#
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
$bin_dir       = $list[0];
$web_dir       = $list[1];
$house_keeping = $list[2];
$data_dir      = $list[3];

#
#---- get a few pieces of necessary information
#
open(FH, "$data_dir/.dare");
while(<FH>){
	chomp $_;
	$dare = $_;
}
close(FH);

open(FH, "$data_dir/.hakama");
while(<FH>){
	chomp $_;
	$hakama = $_;
}
close(FH);

#
#--- add un analyzed data from the last run
#
system("cat $house_keeping/hold_obsid_reanal >> .known_coord");
open(FH, './known_coord');
$chk_cnt = 0;
@known_coord = ();
while(<FH>){
	chomp $_;
	if($_ ne '' || $_ =~ /\s+/){
		push(@known_coord, $_);
		$chk_cnt++;
	}
}
close(FH);

if($chk_cnt == 0){
	exit 1;
}
#
#---- remove duplicates
#
if($chk_cnt > 0){
	$first = shift(@known_coord);
	@new = ($first);
	OUTER:
	foreach $ent (@known_coord){
		$sent = $ent;
		$sent =~ s/\s+//g;
		foreach $comp (@new){
			$scomp = $comp;
			$scomp =~ s/\s+//g;
			if($sent eq $scomp){
				next OUTER;
			}
		}
		push(@new, $ent);
	}
	@known_coord = @new;
	open(OUT, '>./known_coord');
	foreach $ent (@known_coord){
		print OUT "$ent\n";
	}
}

@obsid_list   = ();
@ra_list      = ();
@dec_list     = ();
@del_ra_list  = ();
@del_dec_list = ();
@name_list    = ();
@inst_list    = ();
@grat_list    = ();
$tot = 0;

#
#---- read input file
#
foreach $ent (@known_coord){
	@atemp = split(/\t+/, $ent);
	@btemp = split(/:/, $atemp[4]);
	@ctemp = split(/\./, $btemp[2]);
	@dtemp = split(//, $ctemp[1]);
	$rcnt = 0;
	foreach (@dtemp){
		$rcnt++;
	}
	@btemp = split(/:/, $atemp[5]);
	@ctemp = split(/\./, $btemp[2]);
	@dtemp = split(//, $ctemp[1]);
	$dcnt = 0;
	foreach (@dtemp){
		$dcnt++;
	}
#
#--- only when the coodinates are 3 decimal accuracy, we use that data
#
	if($rcnt >= 3 && $dcnt >= 3){
		push(@obsid_list, $atemp[0]);
		push(@ra_list, $atemp[4]);
		push(@dec_list, $atemp[5]);
		push(@del_ra_list, $atemp[6]);
		push(@del_dec_list, $atemp[7]);
		push(@name_list, $atemp[3]);
		push(@inst_list, $atemp[1]);
		push(@grat_list, $atemp[2]);
		$tot++;
	}
}

OUTER:
for($k = 0; $k < $tot; $k++){
#
#---- prepare to use arc4gl to get a evt1 fits file
#
	open(OUT, ">./input_line");
	print OUT "operation=retrieve\n";
	print OUT "dataset=flight\n";
	if($inst_list[$k] =~ /ACIS/i){
		print OUT "detector=acis\n";
	}elsif($inst_list[$k] =~ /HRC/i){
		print OUT "detector=hrc\n";
	}
	print OUT "level=1\n";
	print OUT "filetype=evt1\n";
	print OUT "obsid=$obsid_list[$k]\n";
	print OUT "go\n";
	close(OUT);
#
#---- here is the arc4gl 
#
	system("echo $hakama |/home/ascds/DS.release/bin/arc4gl -U$dare -Sarcocc -i./input_line"); 
	system("rm ./input_line");
	
	@ztemp = split(/-/, $inst_list[$k]);
	$head = lc ($ztemp[0]);
	
	$name = "$head".'*.fits*';
	$fits_file = `ls $name`; 
	$fits_file =~ s/\s+//g;
#
#---- if the observation is not in archive yet, hold for the
#---- future analysis
#
	if($fits_file eq ''){
		open(OUT, ">>$hosue_keeping/hold_obsid_reanal");
		print OUT "$obsid_list[$k]\t";
		print OUT "$inst_list[$k]\t";
		print OUT "$grat_list[$k]\t";
		print OUT "$name_list[$k]\t";
		print OUT "$ra_list[$k]\t";
		print OUT "$dec_list[$k]\t";
		print OUT "$del_ra_list[$k]\t";
		print OUT "$del_dec_list[$k]\n";
		close(OUT);
		next OUTER;
	}
	system("gzip -d ./$fits_file");
	@ztemp = split(/\./, $fits_file);

	$name = "$ztemp[0]".'.fits';
	$fits_file = $name;
	$opt_ra    = $ra_list[$k];
	$opt_dec   = $dec_list[$k];
	$del_ra    = $del_ra_list[$k];
	$del_dec   = $del_dec_list[$k];
	$inst      = $inst_list[$k];
	$grat      = $grat_list[$k];
#
#---  find the source position, and take a positional difference between 
#---  that nad simbat optical locaiton
#

	find_coord();

#
#--- open output file according to the instrument
#
	if($inst_list[$k] =~ /ACIS-S/i){
		open(OUT, ">>$web_dir/Data/acis_s_data");
	}elsif($inst_list[$k] =~ /ACIS-I/i){
		open(OUT, ">>$web_dir/Data/acis_i_data");
	}elsif($inst_list[$k] =~ /HRC-S/i){
		open(OUT, ">>$web_dir/Data/hrc_s_data");
	}elsif($inst_list[$k] =~ /HRC-I/i){
		open(OUT, ">>$web_dir/Data/hrc_i_data");
	}
	@ctemp = split(//, $obsid_list[$k]);
	$tcnt  = 0;
	foreach(@ctemp){
		$tcnt++;
	}
	if($tcnt == 1){
		$obsid_disp = '000'."$obsid_list[$k]";
	}elsif($tcnt == 2){
		$obsid_disp = '00'."$obsid_list[$k]";
	}elsif($tcnt == 3){
		$obsid_disp = '0'."$obsid_list[$k]";
	}else{
		$obsid_disp = $obsid_list[$k];
	}
		
	printf OUT "%8.2f\t",$acc_date;
	print  OUT "$obsid_disp\t";
#	printf OUT "%15s\t", $object;
	printf OUT "%15s   \t", $name_list[$k];
	printf OUT "%5.9f\t",$ra;
	printf OUT "%5.9f\t",$dec;
	printf OUT "%6.4f\t",$diff_x;
	printf OUT "%6.4f\t",$diff_y;
	print  OUT "$grat\n";
	close(OUT);

	system("rm ./*fits*");
#	system("mv *fits* Data_used/");
}

system('cat ./known_coord >>  ./known_coord_old');

foreach $r_file ('acis_s_data', 'acis_i_data', 'hrc_s_data', 'hrc_i_data'){
#
#---- put the list into time order
#---- also remove any objects farther than 5 arc sec
#---- if the coordinates are 0.0000, the script could not find a soruce,
#---- and hence we move it into a rejected_list
#
	open(FH, "$web_dir/Data/$r_file");
	@temp = ();
	while(<FH>){
		chomp $_;
		push(@temp, $_);
	}
	close(FH);
	@new = sort{$a<=>$b} @temp;
	open(OUT, "> $web_dir/Data/$r_file");
	open(OUT2, ">> $web_dir/Data/rejected_list");
	foreach $ent (@new){
		@atemp = split(/\t/, $ent);
		$first = abs ($atemp[5]);
		$second = abs ($atemp[6]);
		if($atemp[3] == 0.0 || $atemp[4] == 0.0){
			print OUT2"$ent\t$r_file\n";
		}elsif($first < 5 && $second < 5){
			print OUT "$ent\n";
		}else{
			print OUT2 "$ent\t$r_file\n";
		}
	}
	close(OUT);
	close(OUT2);
}

####################################################################
### find_coord: find a source location from fits file           ####
####################################################################

sub find_coord{
	
	$deg = 0.017453292;			# deg to rad
	
#
#---- select a window acoording to the instrument
#
	if($inst =~ /ACIS/i){
        	system("dmcopy \"./$fits_file\[bin x=3500:4900:1,y=3650:5100:1\]\" ./temp_img.fits");
	}elsif($inst =~ /HRC-I/i){
		system("dmcopy \"./$fits_file\[bin x=16000:17000:1,y=16000:17000:1\]\" ./temp_img.fits");
	}elsif($inst =~ /HRC-S/i){
		system("dmcopy \"./$fits_file\[bin x=32500:33500:1,y=32500:33500:1\]\" ./temp_img.fits");
	}

#
#---- use celldetect to find source locations in the file
#
#	system("celldetect ./temp_img.fits  ./out.fits clobber=yes");
	system("wavdetect ./temp_img.fits  ./out.fits ./cell.fits ./t_img.fits ./bkg.fits expfile=none  clobber=yes");
#
#---- geta few information we need
#	
	system(" dmlist \"out.fits\" opt=head > zout");
	open(FH, './zout');
	while(<FH>){
		chomp $_;
		if($_ =~ /DATE-OBS/){
			@btemp = split(/\s+/, $_);
			$date_obs = $btemp[2];
		}
		if($_ =~ /OBS_ID/){
			@ctemp = split(/\s+/, $_);
			$obsid = $ctemp[2];
			$obsid =~ s/\s+//g;
		}
		if($_ =~ /OBJECT/){
			@dtemp = split(/\s+/, $_);
			$object = $dtemp[2];
		}
		if($_ =~ /ROLL_NOM/){
			@etemp = split(/\s+/, $_);
			$roll_nom = $etemp[2];
		}
	}
	close(FH);
#
#---- modify ra and dec format to degree and correct a proper motion
#	
	get_new_ra_dec();
	
#
#---- assuming the brightest source is the source we wanted, find which one is the source
#
	system("dmlist \"out.fits[cols net_counts,ra,dec]\" opt=data > zout");
	open(FH, './zout');
	@net_cnt = ();
	$atot    = 0;
	while(<FH>) {
		chomp $_;
		@ctemp = split(/\s+/, $_);
		if($ctemp[1] =~ /\d/){
			push(@net_cnt, $ctemp[2]);
			%{data.$ctemp[2]}= ( ra =>["$ctemp[3]"],
					     dec => ["$ctemp[4]"]);
			$atot++;
		}

	}
	close(FH);
	system("rm ./temp_img.fits ./out.fits  ./zout");

	@sorted_cnt = sort{$b<=>$a} @net_cnt;
	$ra       = 'na';
	$dec      = 'na';
	$diff_ra  = 'na';
	$diff_dec = 'na';
	for($i = 0; $i < $atot; $i++){
		$ra  = ${data.$sorted_cnt[$i]}{ra}[0];
		$dec = ${data.$sorted_cnt[$i]}{dec}[0];
		$diff_ra  = 3600*($ra  - $c_ra);
		$diff_dec = 3600*($dec - $c_dec);
		if(abs($diff_ra) < 10 && abs($diff_dec) < 10){
			last;
		}
	}
#
#--- rotate the coordinate so that we can find CCD coordinates y and z (here they are called x and y)
#	
	if($diff_ra ne 'na' && $diff_dec ne 'na'){
		$diff_x = sqrt($diff_ra**2 + $diff_dec**2) * cos(atan2($diff_dec, $diff_ra) + $roll_nom * $deg);
		$diff_y = sqrt($diff_ra**2 + $diff_dec**2) * sin(atan2($diff_dec, $diff_ra) + $roll_nom * $deg);
	}else{
		$diff_x = 'na';
		$diff_y = 'na';
	}
}


###########################################################
### get_new_ra_dec: correct ra and dec for proper motion ##
###########################################################

sub get_new_ra_dec{

	@asave = split(/:/, $opt_ra);
	$tra = 15*($asave[0] + $asave[1]/60 + $asave[2]/3600);

	@save = split(/:/, $opt_dec);
	$sign = 1;
	if($save[0] < 0){
		$sign = -1;
	}
	$tdec = abs($save[0]) + $save[1]/60 + $save[2]/3600;
	$tdec *= $sign;

	$dra = $del_ra/3600./1000.0;
	$ddec = $del_dec/3600./1000.0;
	
	$time = $date_obs;
	ch_time_form();
	
	$time = ($acc_date - 163)/365;
	$c_ra = $tra + $dra*$time;
	$c_dec = $tdec + $ddec*$time;
}
	
########################################################
###  ch_time_form: changing time format           ######
########################################################

sub ch_time_form {
                @atemp = split(/T/,$time);
                @btemp = split(/-/,$atemp[0]);

                $year = $btemp[0];
                $month = $btemp[1];
                $day  = $btemp[2];
                conv_date();

                @ctemp = split(/:/,$atemp[1]);
                $hr = $ctemp[0]/24.0;
                $min = $ctemp[1]/1440.0;
                $sec = $ctemp[2]/86400.0;
                $hms = $hr+$min+$sec;
                $acc_date = $acc_date + $hms;
}
###########################################################################
###      conv_date: modify data/time format                           #####
###########################################################################

sub conv_date {

        $acc_date = ($year - 1999)*365;
        if($year > 2000 ) {
                $acc_date++;
        }elsif($year >  2004 ) {
                $acc_date += 2;
        }elsif($year > 2008) {
                $acc_date += 3;
        }elsif($year > 2012) {
                $acc_date += 4;
        }

        $acc_date += $day - 1;
        if ($month == 2) {
                $acc_date += 31;
        }elsif ($month == 3) {
                if($year == 2000 || $year == 2004 || $year == 2008 || $year == 2012) {
                        $acc_date += 59;
                }else{
                        $acc_date += 58;
                }
        }elsif ($month == 4) {
                $acc_date += 90;
        }elsif ($month == 5) {
                $acc_date += 120;
        }elsif ($month == 6) {
                $acc_date += 151;
        }elsif ($month == 7) {
                $acc_date += 181;
        }elsif ($month == 8) {
                $acc_date += 212;
        }elsif ($month == 9) {
                $acc_date += 243;
        }elsif ($month == 10) {
                $acc_date += 273;
        }elsif ($month == 11) {
                $acc_date += 304;
        }elsif ($month == 12) {
                $acc_date += 334;
        }
	$acc_date = $acc_date - 202;
}

