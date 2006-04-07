#!/usr/local/bin/perl5.8.6
use Astro::SIMBAD;
use Query_mta;
use Astro::SIMBAD::Result;
use Astro::SIMBAD::Result::Object;
use Data::Dumper;

#################################################################################
#										#
#	simbad_query.perl: go to SIMBAD site and retrieve coordinates inf	#
#										#
#	author: t. isobe (tisobe@cfa.harvard.edu)				#
#										#
#	last update: 03/21/2006							#
#										#
#	THIA SCRIPT MUST HAVE QUER_mta.pm IN WORKING DIRECTORY			#
#										#
#################################################################################

#
#--- read a target name from a file ./tag_name
#
$target = `cat ./tag_name`;
system("rm ./tag_name");
chomp $target;
#
#--- initialize a file content
#
open(OUT, '>./simbad_out');
print OUT "unprocessed\n";
close(OUT);

#
#--- call SIMBAD module and set new query
#
my $query = new Query_mta();
$query->url( "simbad.u-strasbg.fr" );
$query->target($target);
$query->error(0);
$frame = $query->frame();
#
#--- here is actual contact to SIMBAD	
#
my $object = $query->querydb();
@objects = $object->objects();

foreach  $obj (@objects){
       	$ra = $obj->ra();
       	$dec = $obj->dec();
	@ctemp = split(/\s+/, $ra);
	$hh = $ctemp[0];
	$mm = $ctemp[1];
	$ss = $ctemp[2];
	$ra = "$hh:$mm:$ss";

	@ctemp = split(/\s+/, $dec);
	$dd = $ctemp[0];
	$dm = $ctemp[1];
	$ds = $ctemp[2];
	$dec = "$dd:$dm:$ds";
#
#----  find proper motion values
#	
       	$pm = $obj->pm();
	
	$line = "$ra\t$dec\t$$pm[0]\t$$pm[1]";
	open(OUT, '>./simbad_out');
	print OUT "$line\n";
	close(OUT);
}
