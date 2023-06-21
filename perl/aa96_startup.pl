#!/usr/bin/perl -w
# Script to create AA project
# HB 2008/08/07
# TODO update the reference v/v ...
# add: consistent ida name, create new flaDirect
# @note no diff from version 1.5

use Data::Dumper;
use libaa;

$scriptName = 'AA96_STARTUP.PL';
$version = '1.7';
$vdate = '2010/06/18';

print "#$scriptName v$version $vdate\n";

# ------------ DEFAULT LOCATION ----------------------
#$starDir = 'star';
$scriptDir = 'bat';
$docDir = 'doc';
$graphDir = 'graph';
$paramDir = 'params';
$aa96_script = 'aa96_scripts.pl';
# ------------ END DEFAULT ---------------------------

$root = $ENV{'AA_DIR'};
$defaultIdaParamsFile = $root . '/' . $paramDir . '/defaultIda.param';
%idaParams = readParams($defaultIdaParamsFile);

@paramFiles = <*.param>;

$oldParamFile = '';
foreach (@paramFiles) {
	if (/[^Ida].*\.param$/i) {
		$oldParamFile = $_;
		last;
	}		
}

$oldParamFile = getInputPersistence("24nm project file (e.g.: chlamy.param)", $oldParamFile);
$projName = $oldParamFile;
$projName =~ s/\.param//g;

%odaParams = readParams($oldParamFile);
#$defaultLRRefFile = $odaParams{"LowResReference"};
#$defaultLRRefFile =~ s/_ref_low\.spi$/_ida_v1_low\.spi/i;
$defaultRefFile = $odaParams{"Reference"};
$defaultRefFile =~ s/_ref_masked\.spi$/_ida_v1_ref_masked\.spi/i;
$defaultMask = $odaParams{"Mask"};
$defaultMask =~ s/_3dmask/_ida_3dmask/i;

$idaParams{"PixelSize"} = $odaParams{"PixelSize"}; 
$idaParams{"ExtractedParticleRadius"} = $odaParams{"ExtractedParticleRadius"};
#$idaParams{"LowResReference"} = getInputPersistence("Low Resolution Reference File", $defaultLRRefFile);
$idaParams{"Reference"} = getInput("Ida Reference File", $defaultRefFile);
$idaParams{"Mask"} = getInput("Mask File", $defaultMask);
$idaParams{"NumberOfProcessors"} = getInput("Number of processors used:", $odaParams{"NumberOfProcessors"});

# Update parameters
$listFile = 'list_' . $projName . '.txt';
$paramFile = $projName . 'Ida.param';
%params = readParams($oldParamFile);
# print Dumper(%params); # DEBUG

# Create directories
print "Create directories\n";
if (!createDir($docDir, $scriptDir, $graphDir)) {
	&terminate();
}
print "Done!\n";

print "Create Ida list file ...\n";
$listIdaFile = $listFile;
$listIdaFile =~ s/\.txt$/_ida_v1\.txt/g;

if (-e $listIdaFile) {
	print "\"$listIdaFile\" exists. Overwrite (Y/N): ";
	$doOverwrite = <>;
	chomp $doOverwrite;
} else {
	if (!createIdaListFile($listFile)) {
		&terminate();
	}
}

if (lc($doOverwrite) eq "y") {
	if (!createIdaListFile($listFile)) {
		&terminate();
	}
}

# Create new param
$idaParams{"PixelSize"} = $params{"PixelSize"};
$idaParams{"IdaPeriod"}=4*$params{"Period"}; # For backward compatible
$idaParams{"Period"}=4*$params{"Period"};
$idaParams{"TiltAngleFile"}=$params{"TiltAngleFile"};

print "Create new param ...\n";
$idaParams{"ListFile"}= 'list_' . $projName . '_ida_v1.txt';
$idaParams{"AverageFile"}= $projName .  '_ida_v1_avg.spi';
$idaParams{"WeightFile"}= 'weight_' . $projName . '_ida_v1_avg.spi';
$idaParams{"CorrectedAverageFile"} = $projName .  '_ida_v1_avg_cr.spi';
writeParams(\%idaParams, $paramFile);
print "\t${projName}Ida.param created\n";
print "Done!\n";

# Create script
print "Generate scripts ..\n";
my $cmd = $aa96_script . " $listIdaFile $paramFile 0";
system($cmd);
print "Done!\n";

print "\nThat's all you need!!\n";


sub terminate {
	print "Program terminated!!!\n";
	exit(1);
}


sub createIdaListFile {
	my ($listFile) = shift;
	$listFile =~ /(.*)\.txt/i;
	$listName = $1;
	eval {
		open (FILEHDL, $listFile) || die "Cannot open $listFile. $!\n";
		open (LSTHDL, ">${listName}_ida_v1.txt") || die "Cannot open file. $!\n";		
	};
	if ($@) { print $@; return 0;};

    my $currtime = time();
    my @timelist = localtime($currtime);
    my $year = $timelist[5] + 1900;
	my $month = $timelist[4]+1;
	print LSTHDL "\#$timelist[3]-$month-$year  $timelist[2]:$timelist[1]:$timelist[0]\n";

	while (<FILEHDL>) {
		if (/\#/) { next;}
		if (/^(\S+)\s+(\S+)\s+(\d)/i) {
				my $docFile = $docDir . '/doc_total_' . $1 . '.spi';
				open (DOCHDL, "$docFile") || die "Cannot open $docFile. $!\n";
				my @lines = <DOCHDL>;
				close DOCHDL;
				my @transform = split(' ', @lines[int(length @lines/2)]);	
				my $flaDirect = 0;
				if ($transform[2] < 0) {
					$flaDirect = 1;
				}
				
				$_ =~ s/^(.*)_(\d\d\d\s+)(\S+)_(\d\s+)(\d)/$1_ida_v1_$2$3_ida_v1_$4$flaDirect/i;
				
				print LSTHDL 	$_;
		}
	}
	close LSTHDL;

	print "\t${listName}_ida_v1.txt created\n";
	return 1;
}
