#!/usr/bin/perl
# Combine transform documents
# @author HB
# @date 20080730
# 20090913 not write anything when input file is missing

use warnings;
use Data::Dumper;
use LibTransform qw(get_transform_list_from_doc combine_transform_list);
use rwSpi qw(write_data_to_spider_doc);

$scriptName = "COMBINE_XFORM_DOC.PL";
$version = "1.1";
$vdate = "2009/09/13";

print "\#$scriptName $version $vdate\n";

if ($#ARGV < 2) {
	&print_usage();
	exit(0);
}

$outputFile = $ARGV[$#ARGV];


$doc01 = $ARGV[0];
if (!(-e $doc01)) {
	print "$doc01 does not exist\n";
	exit(0);
}

@transform01 = get_transform_list_from_doc($doc01);
	
#print Dumper(@transform01);

for ($i = 1; $i < $#ARGV; $i++) {
	if (!(-e $ARGV[$i])) {
			print "$ARGV[$i] does not exist.\n";
			exit(0);
	}
	@transform02 = get_transform_list_from_doc($ARGV[$i]);
	$transform03 = combine_transform_list(\@transform01, \@transform02);
	if ($transform03 == -1) {
		print "Error combining @ARGV !\n";
		exit(0);
	}
	@transform01 = @{$transform03};
}

&write_data_to_spider_doc($transform03, $outputFile);

print "Writing $outputFile. Done!\n";	

sub print_usage {
	print "Usage: combine_xform_doc.pl input1 input2 ... output\n";
}
