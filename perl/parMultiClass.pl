#!/usr/bin/perl -w

use libaa;

$root = $root = $ENV{'AA_DIR'};
$scriptDir = 'bat';
$templateDir = $templateDir = $root . '/template';

if ($#ARGV < 2) {
	print "Usage: parMultiClass.pl listFile paramFile number_of_cpus\n";
	exit;
}

$listFile = $ARGV[0];
$paramFile = $ARGV[1];
$number_of_cpus = $ARGV[2];

open(LSTHDL, $listFile) || die "Cannot open $listFile. $!\n";

@list = ();
while (<LSTHDL>) {
    if (/\#/) { next;}
	if (/^\s*$/) { next;}
    if (/^\s*(\S+)\s+(\S+)\s+\d/i) {		
		push(@list, $_);
    }
}

$number_of_records = $#list + 1;
$pieceSize = int($number_of_records/$number_of_cpus) + 1;


for ($i = 0; $i < $number_of_cpus; $i++) {
	$pieceListFile = $listFile . '.p' . $i; 
	open(PLHDL, ">$pieceListFile") || die "Cannot create $pieceListFile	. $!\n";
	$endNo = ($i+1)*$pieceSize;
	if ($endNo > $number_of_records) {
		$endNo = $number_of_records;
	}
	foreach ($j = $i*$pieceSize; $j < $endNo; $j++) {
		print PLHDL "$list[$j]";
	}
	close PLHDL;
}

%params = readParams($paramFile);
$origAvgFile = $params{"AverageFile"};

# Writing paralell script
for ($i = 0; $i < $number_of_cpus; $i++) {
	$params{"ListFile"} = $listFile . '.p' . $i;
	$params{"AverageFile"} = $origAvgFile;
	$params{"AverageFile"} =~ s/\.spi/_p$i\.spi/i;
	$newParamFile = $paramFile . '.p' . $i;
	writeParams(\%params, $newParamFile);
	libaa::writeTemplateToMScript("${scriptDir}/multirefClassification_p${i}.m", "${templateDir}/multirefClassification.template", $newParamFile);	
}

# Writing merge script
libaa::writeTemplateToMScript("${scriptDir}/multirefClassificationMerge.m", "${templateDir}/multirefClassificationMerge.template", $paramFile)


