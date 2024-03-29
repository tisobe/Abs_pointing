#!/soft/ascds/DS.release/ots/bin/perl

use DBI;
use DBD::Sybase;

#################################################################################
#										#
#	abs_pointing_find_candidate.perl: this script reads MTA photon 		#
#				monitoring page	extracts obsid and instrument   #
#				name, grating name.				#
#										#
#	author: t. isobe (tisobe@cfa.harvard.edu)				#
#	last update: Mar 16, 2011						#
#										#
#################################################################################

############################################################################
#
#--- read directory list
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

############################################################################

#
#---- a previously examined obsid list
#

@obsid_list = ();
open(FH, "$house_keeping/obsid_list");
while(<FH>){
	chomp $_;
	push(@obsid_list, $_);
}
close(FH);

@star_list = (achernar, mira, polaris, algol, aldebaran, rigel, capella, betelgeuse, canopus, sirius, castor, procyon, pollux, regulus, spica, arcturus, antares, vega, altair, deneb, fomalhaut);

#
#--- name of constellations
#

open(FH, "$bdata_dir/Abs_pointing/constellation");
@constellation = ();
while(<FH>){
        chomp $_;
        push(@constellation, $_);
}
close(FH);

#
#----- get recently processed data
#

open(FH,'/data/mta_www/mp_reports/events/mta_events.html');
@data_list = ();
while(<FH>){
	chomp $_;
	if($_ =~ /acis/){
		@atemp = split(/true\">/, $_);
		@btemp = split(/<\/A/, $atemp[1]);
		push(@data_list, $btemp[0]);
	}elsif($_ =~ /hrc/){
		@atemp = split(/true\">/, $_);
		@btemp = split(/<\/A/, $atemp[1]);
		push(@data_list, $btemp[0]);
	}
}
close(FH);


#-------------------------------------------------
#--- open up database and read target name etc
#-------------------------------------------------

#
#---  database username, password, and server
#

$db_user="browser";
$server="ocatsqlsrv";
$db_passwd =`cat $house_keeping/.targpass`;
chomp $db_passwd;

open(OUT, '>./candidate_list');

OUTER:
foreach $obsid (@data_list){
	foreach $comp (@obsid_list){
		if($obsid == $comp){
			next OUTER;
		}
	}

#
#--- if this obsid is not processed before,  open connection to sql server
#
        my $db = "server=$server;database=axafocat";
        $dsn1 = "DBI:Sybase:$db";
        $dbh1 = DBI->connect($dsn1, $db_user, $db_passwd, { PrintError => 0, RaiseError => 1});

        $sqlh1 = $dbh1->prepare(qq(select
                obsid,targid,seq_nbr,targname,grating,instrument
        from target where obsid=$obsid));
        $sqlh1->execute();
        @targetdata = $sqlh1->fetchrow_array;
        $sqlh1->finish;

        $targid     = $targetdata[1];
        $seq_nbr    = $targetdata[2];
        $targname   = $targetdata[3];
	$grating    = $targetdata[4];
	$instrument = $targetdata[5];
	if($targname =~ /:/){
		@atemp = split(/:/, $targname);
		$targname = $atemp[0];
	}

	$targid     =~ s/\s+//g;
        $seq_nbr    =~ s/\s+//g;
#       $targname   =~ s/\s+//g;
	$grating    =~ s/\s+//g;
	$instrument =~ s/\s+//g;

#
#----- print out only observations done with a grating, or clearly it is a point sources
#
        if($grating eq 'NONE'){
#
#--- we assume that if the name starts from "HD" it is a star
#
                if($targname =~ /HD/i){
                        print OUT "$obsid:$targname:$instrument:$grating\n";
                }else{
                        $chk = 0;
#
#--- if the name is in the famous star list, keep it
#
                        foreach $ent (@star_list){
                                if($targname =~ /$ent/i && $targname !~ /gal/i
                                        && $targname !~ /nebula/i && $targname !~ /dwarf/i){
                                        print OUT "$obsid:$targname:$instrument:$grating\n";
                                        $chk = 1;
                                }
                        }

                        if($chk == 0){
#
#--- if the name contains constration name, it is quite possible that it is a star
#--- such as alpha ori
#
                                foreach $ent (@constellation){
                                        if($targname =~ /$ent/i && $targname !~ /gal/i
                                                && $targname !~ /nebula/i && $targname !~ /dwarf/i){
                                                print OUT "$obsid:$targname:$instrument:$grating\n";
                                        }
                                }
                        }
                }
        }else{
#
#--- this is a grating case, and we asume that all of them are point sources
#
                print OUT "$obsid:$targname:$instrument:$grating\n";
        }
}
close(OUT);



