#!/usr/bin/perl -w
# Script to create all aa 96nm script
# HB 2008/08/07

use lib qw(/mol/ish/Data/programs/axoneme_aln/perl/lib);
use libaa;
use Data::Dumper;

$scriptName = "AA96_SCRIPT.PL";
$version = '1.0';
$vdate = '2008/10/28';

print "\#$scriptName v$version $vdate\n";

# Program default
$scriptDir = 'bat';
$starDir = 'star';
$docDir = 'doc';
$root = $root = $ENV{'AA_DIR'};
$perlDir = 'perl';
$templateDir = $root . '/template';

if ($#ARGV < 2 && $#ARGV != -1) {
	print "Usage: aa96_scripts.pl listFile paramFile scriptType\n";
	print "\tparamFile: e.g. chlamy.param.v1\n";
	print "\tlistFile: e.g. list_chlamy_ida_v1.txt\n";
	print "\tscriptType: e.g. 0\n";
	exit;
}

my $listFile = '';
my $paramFile = '';
my $scriptType = 0;

if ($#ARGV == 2) {
	$paramFile = $ARGV[1];
	$listFile = $ARGV[0];
	$scriptType = $ARGV[2];
} else {
	opendir (DIRFILEHDL, '.') || die "Cannot open currentDir. $!";
	while ($fileName = readdir(DIRFILEHDL)) {
		if ($fileName =~ /Ida.param$/i) {
			$paramFile = $fileName;
		}
		if ($fileName =~ /^list.*ida_v1\.txt$/i) {
			$listFile = $fileName;
		}
	}
	closedir DIRFILEHDL;

	$listFile = getInput("List file", $listFile);
	$paramFile = getInput("Parameter file", $paramFile);

	print "Script Type [0]:\n";
	printf "\t%16s\n", "All[0]";
	printf "\t%16s %16s\n", "FitIda[1]", "IntraIdaAln[2]";
	printf "\t%16s %16s %16s\n", "ShiftIdaAln[3]", "PickIda[4]", "CbnIdaDoc[5]";
	printf "\t%16s %16s\n", "InterIdaAln[6]", "CbnAllIdaDoc[7]";
	printf "\t%16s %16s %16s\n", "CalcAvg[8]", "CalcWeight[9]", "WeightedAvg[10]";
	printf "\t%16s\n", "CleanUp[11]";
	printf "\n\t%16s\n", "FitExtension[12]";
	print ": ";
	$scriptType = <>;
	chomp $scriptType;
}

print "List file: $listFile\nParameter File: $paramFile\n";

if (-d $scriptDir) {
	print "\t$scriptDir directory already exists\n";
} else {
	print "\tmkdir $scriptDir\n";
	mkdir ($scriptDir) || die "Cannot create $scriptDir. $!\n";
}

for ($scriptType) {
	/^0$/ && do {&writeTemplateToMScript("${scriptDir}/idaFit.m", "${templateDir}/idaFit.template", $paramFile);
					&writeIntraScript("${scriptDir}/intraAlnIdaV1.bat" , $listFile, $paramFile);
					&writeShiftScript("${scriptDir}/shiftIdaAln.bat" , $listFile, $paramFile);
					&writePickScript("${scriptDir}/pickIda.bat" , $listFile, $paramFile);
					&writeCbnScript("${scriptDir}/cbnDocIdaV1.bat" , $listFile, ["$docDir/doc_init_", "$docDir/doc_intra_", "$docDir/doc_shift_", "$docDir/doc_cbn_"]);
					&writeInterScript("${scriptDir}/interAlnIdaV1.bat" , $listFile, $paramFile);
					&writeCbnScript("${scriptDir}/cbnAllDocIdaV1.bat" , $listFile, ["$docDir/doc_cbn_", "$docDir/doc_inter_", "$docDir/doc_total_"]);
					&writeAvgScript("${scriptDir}/avgIdaV1.bat" , $listFile, $paramFile);
					&writeTemplateToMScript("${scriptDir}/calcMwWeightIdaV1.m", "${templateDir}/calcMwWeight.template" , $paramFile);
					&writeTemplateToMScript("${scriptDir}/weightedAvgIdaV1.m", "${templateDir}/weightedAvg.template" , $paramFile);
					&writeIdaScript("${scriptDir}/idaScript.bat", $paramFile);
					&writeCleanUpScript("${scriptDir}/cleanUpIda.bat"); last;};
	/^1$/ && do {&writeTemplateToMScript("${scriptDir}/idaFit.m", "${templateDir}/idaFit.template", $paramFile); last;};
	/^2$/ && do {&writeIntraScript("${scriptDir}/intraAlnIdaV1.bat" , $listFile, $paramFile); last;};
	/^3$/ && do {&writeShiftScript("${scriptDir}/shiftIdaAln.bat" , $listFile, $paramFile); last;};
	/^4$/ && do {&writePickScript("${scriptDir}/pickIda.bat" , $listFile, $paramFile); last;};
	/^5$/ && do {&writeCbnScript("${scriptDir}/cbnDocIdaV1.bat" , $listFile, ["$docDir/doc_init_", "$docDir/doc_intra_", "$docDir/doc_shift_", "$docDir/doc_cbn_"]); last;};
	/^6$/ && do {&writeInterScript("${scriptDir}/interAlnIdaV1.bat" , $listFile, $paramFile); last;};	
	/^7$/ && do {&writeCbnScript("${scriptDir}/cbnAllDocIdaV1.bat" , $listFile, ["$docDir/doc_cbn_", "$docDir/doc_inter_", "$docDir/doc_total_"]); last;};
	/^8$/ && do {&writeAvgScript("${scriptDir}/avgIdaV1.bat" , $listFile, $paramFile); last;}; 
	/^9$/ && do {&writeTemplateToMScript("${scriptDir}/calcMwWeightIdaV1.m", "${templateDir}/calcMwWeight.template" , $paramFile); last;};
	/^10$/ && do {&writeTemplateToMScript("${scriptDir}/weightedAvgIdaV1.m", "${templateDir}/weightedAvg.template" , $paramFile); last;};
	/^11$/ && do {&writeCleanUpScript("${scriptDir}/cleanUpIda.bat"); last;};
	/^12$/ && do {
		%params = readParams($paramFile);
		$params{"ExtensionName"} = getInput("Extension Name", $params{"ExtensionName"});
		$params{"OriginShiftX"} = getInput("Origin shift in X", $params{"OriginShiftX"});
		$params{"OriginShiftY"} = getInput("Origin shift in Y", $params{"OriginShiftY"});
		$params{"OriginShiftZ"} = getInput("Origin shift in Z", $params{"OriginShiftZ"});
		$exName = $params{"ExtensionName"};
		&writeParams(\%params, $paramFile);
		&writeTemplateToMScript("${scriptDir}/${exName}Fit.m", "${templateDir}/exFit.template" , $paramFile); last;};
	die "Unknown value for script type: $scriptType";
};

exit;

#---------------------
# Sub writeInterScript
#---------------------

sub writeInterScript {
	my ($scriptFile, $listFile, $paramFile) = @_;
	my %params = readParams($paramFile);
	my %list = parseList($listFile);

	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!";

	print FILEHDL "#Linking star and doc file\n";
	foreach (sort {$a cmp $b} (keys %list)) {
		print FILEHDL "ln -s $docDir/doc_cbn_$list{$_}.spi .\n";
		print FILEHDL "ln -s $starDir/$_.star\n";
	}	

	my $generalArg = ' -doc_output_prefix doc_inter_';
	$generalArg = $generalArg . ' -extract ' . $params{"ExtractedParticleRadius"};
	$generalArg = $generalArg . ' -bandpass ' . $params{"LowPassFreq"}. ',' . $params{"HighPassFreq"} . ',' . $params{"Sigma"};
	$generalArg = $generalArg . ' -box ' .  $params{"InterCCLowerX"} . ',' . $params{"InterCCUpperX"} . ',' . $params{"InterCCLowerY"} . ',' . $params{"InterCCUpperY"} . ',' . $params{"InterCCLowerZ"} . ',' . $params{"InterCCUpperZ"}; 
	$generalArg = $generalArg . ' -ref ' . $params{"LowResReference"};
	$generalArg = $generalArg . ' -search_radius ' . $params{"InterSearchRadius"};

	my $specificArg = '';
	foreach (sort {$a cmp $b} (keys %list)) {
		$specificArg = ' -star ' . $_ . '.star';
		$specificArg = $specificArg . ' -doc_init doc_cbn_' . $list{$_}  . '.spi';
		my $cmd = 'mtb_auto_aln.pl' . $generalArg . $specificArg . ' ' . $list{$_};
		print FILEHDL "$cmd\n";
	}	
	close FILEHDL;
	# Set permission to run
	&finishWriting($scriptFile);
	return 1;
}

sub writeIntraScript {
	my ($scriptFile, $listFile, $paramFile) = @_;
	my %params = readParams($paramFile);
	my %list = parseList($listFile);

	my $generalArg = ' -doc_output_prefix doc_intra_';
	$generalArg = $generalArg . ' -extract ' . $params{"ExtractedParticleRadius"};
	$generalArg = $generalArg . ' -bandpass ' . $params{"LowPassFreq"}. ',' . $params{"HighPassFreq"} . ',' . $params{"Sigma"};
	$generalArg = $generalArg . ' -box ' .  $params{"IntraCCLowerX"} . ',' . $params{"IntraCCUpperX"} . ',' . $params{"IntraCCLowerY"} . ',' . $params{"IntraCCUpperY"} . ',' . $params{"IntraCCLowerZ"} . ',' . $params{"IntraCCUpperZ"}; 
	$generalArg = $generalArg . ' -search_radius ' . $params{"IntraSearchRadius"};
	$generalArg = $generalArg . ' -numAvg ' . $params{"NumberOfParticlesToAverage"};

	my $specificArg = '';

	
	for ($i = 1; $i <= 4; $i++) {
		$scriptFile =~ s/IdaV\d\.bat/IdaV$i\.bat/g;
		open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!";		
		print FILEHDL "ln -s $starDir/*ida_v${i}.star .\n";
		print FILEHDL "ln -s $docDir/doc_init_*ida_v${i}*.spi .\n";
		for (my $j = 0; $j <  $params{"NumberOfProcessors"}; $j++) {
			print FILEHDL "sleep 5\n"; # 
		}

		foreach (sort {$a cmp $b} (keys %list)) {
			my $starFile = $_;
			my $avgFile = $list{$_};
			$starFile =~ s/ida_v1/ida_v$i/g;
			$avgFile =~ s/ida_v1/ida_v$i/g;
			$specificArg = ' -star ' . $starFile . '.star';
			$specificArg = $specificArg . ' -doc_init doc_init_' . $avgFile . '.spi';
			my $cmd = 'mtb_auto_aln.pl' . $generalArg . $specificArg . ' ' . $avgFile;
			print FILEHDL "$cmd\n";
		}	
		close FILEHDL;
		# Set permission to run
		&finishWriting($scriptFile);	
	}
	return 1;
}

sub writeAvgScript {
	my ($scriptFile, $listFile, $paramFile) = @_;
	my %params = readParams($paramFile);
	my %list = parseList($listFile);
	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!";

	print FILEHDL "#Linking star and doc file\n";
	foreach (sort {$a cmp $b} (keys %list)) {
		print FILEHDL "ln -s $docDir/doc_total_$list{$_}.spi .\n";
		print FILEHDL "ln -s $starDir/$_.star\n";
	}	

	my $generalArg = ' -align 0';
	$generalArg = $generalArg . ' -extract ' . $params{"ExtractedParticleRadius"};
	$generalArg = $generalArg . ' -lower_limit ' . $params{"LowerLimit"};


	my $specificArg = '';
	foreach (sort {$a cmp $b} (keys %list)) {
		$specificArg = ' -star ' . $_ . '.star';
		$specificArg = $specificArg . ' -doc_init doc_total_' . $list{$_} . '.spi';
		my $cmd = 'mtb_auto_aln.pl' . $generalArg . $specificArg . ' ' . $list{$_};
		print FILEHDL "$cmd\n";
	}	

	my $output = $params{"AverageFile"};
	$output =~ s/\.spi$//i;

	my $avgCmd = 'spider_avg.pl -output ' . $output . ' -list ' . $listFile;

	print FILEHDL "#Sum\n$avgCmd\n";
	close FILEHDL;
	# Set permission to run
	&finishWriting($scriptFile);
	return 1;
}

sub writeCbnScript {
	my ($scriptFile, $listFile, $listDocPrefix) = @_;
	my %list = parseList($listFile);

	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!";

	my @listDocPrefix = @{$listDocPrefix};
	foreach (@listDocPrefix) {
		my $docPrefix = $_;
		$docPrefix =~ s/$docDir\///g;
		print FILEHDL "mv $docPrefix*spi $docDir\n";
	}

	foreach my $avgFile (sort {$a cmp $b} (values %list)) {				
		my $cmd = $root . '/' . $perlDir . '/combine_xform_doc.pl ';
		foreach my $docPrefix (@listDocPrefix) {
			$cmd = $cmd . $docPrefix . $avgFile . '.spi ';
		}
		print FILEHDL "$cmd\n";
	}	
	close FILEHDL;	# Set permission to run
	&finishWriting($scriptFile);
	return 1;
}


sub writeTemplateToMScript {
	my ($scriptFile, $templateFile, $paramFile) = @_;

	my %params = readParams($paramFile);

	#print Dumper(%params); # DEBUG
	my $batchFile = $scriptFile;
	$batchFile =~ s/\.m$/\.bat/i;
	my $logFile = $batchFile;
	$logFile =~ s/^.*\/(.*)\.bat$/$1\.log/g;

	&deleteIfExists($batchFile);
	&deleteIfExists($scriptFile);

	open (INHDL, $templateFile) || die "Cannot open $templateFile. $!\n";
	open (OUTHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!\n";
	open (OUT2HDL, ">$batchFile") || die "Cannot create $batchFile. $!\n";

	my $headerEnd = 0;
	my $headerStart = 0;
	while (<INHDL>) {
		if (/START HEADER/) {
			$headerStart = 1;
			next;
		}
		if (/END HEADER/) {
			$headerEnd = 1;
			next;
		}

		if ($headerEnd || !$headerStart) {
			print OUTHDL $_;
		} else {
			foreach my $key (keys %params) {
				if (/\#s\#$key\#/i) {
					#print "$params{$key}\n"; # DEBUG
					$_ =~ s/\#s\#$key\#/\'$params{$key}\'/i;
					print OUTHDL $_;
					next;
				} elsif (/\#d\#$key\#/i) {
					#print "$params{$key}\n"; # DEBUG
					$_ =~ s/\#d\#$key\#/$params{$key}/i;
					print OUTHDL $_;
					next;	
				}				
			}	
		}
	}


	print OUT2HDL"nohup matlab -nodisplay < $scriptFile > $logFile\n";

	close INHDL;
	close OUTHDL;
	close OUT2HDL;

	# Set permission to run
	&finishWriting($scriptFile);
	&finishWriting($batchFile);

	return 1;
}

sub writePickScript {
	my ($scriptFile, $listFile, $paramFile) = @_;
	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!";

	print FILEHDL "mv doc_init_* doc_intra_* doc_shift_* $docDir\n";	
	print FILEHDL "${root}/${perlDir}/pick_ida.pl $listFile 1 > pickIda.log\n";

	close FILEHDL;

	# Set permission to run
	&finishWriting($scriptFile);

	return 1;
}

sub writeShiftScript {
	my ($scriptFile, $listFile, $paramFile) = @_;
	my %params = readParams($paramFile);
	my %list = parseList($listFile);
	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!";

	my $generalArg = ' -doc_prefix doc_shift_ -search_type 1 -range 1,4';
	$generalArg = $generalArg . ' -mask ' . $params{"Mask"};
	$generalArg = $generalArg . ' -bandpass ' . $params{"LowPassFreq"}. ',' . $params{"HighPassFreq"} . ',' . $params{"Sigma"};
	$generalArg = $generalArg . ' -box ' .  $params{"ShiftCCLowerX"} . ',' . $params{"ShiftCCUpperX"} . ',' . $params{"ShiftCCLowerY"} . ',' . $params{"ShiftCCUpperY"} . ',' . $params{"ShiftCCLowerZ"} . ',' . $params{"ShiftCCUpperZ"}; 
	$generalArg = $generalArg . ' -ref ' . $params{"LowResReference"};

	my $specificArg = '';
	foreach (sort {$a cmp $b} (keys %list)) {
		my $inputFile = $list{$_};
		$inputFile =~ s/ida_v1/ida_v\\\*/g;
		my $outputFile = $list{$_};
		$outputFile =~ s/ida_v1/ida_all/g;
		$specificArg = ' -name ' . $inputFile;
		my $cmd = 'spider_aln.pl' . $generalArg . $specificArg . ' ' . $outputFile;
		print FILEHDL "$cmd\n";
	}	
	close FILEHDL;

	&finishWriting($scriptFile);

	return 1;
}	

sub writeIdaScript {
	my ($scriptFile, $paramFile) = @_;

	my %params = readParams($paramFile);
	my $numberOfProcessors = $params{"NumberOfProcessors"};

	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!";

	print FILEHDL "./$scriptDir/idaFit.bat\n";
	print FILEHDL "nohup batch_job_submit.pl $numberOfProcessors ./$scriptDir/intraAlnIdaV1.bat > intraAlnIdaV1.log\n";
	print FILEHDL "nohup batch_job_submit.pl $numberOfProcessors ./$scriptDir/intraAlnIdaV2.bat > intraAlnIdaV2.log\n";
	print FILEHDL "nohup batch_job_submit.pl $numberOfProcessors ./$scriptDir/intraAlnIdaV3.bat > intraAlnIdaV3.log\n";
	print FILEHDL "nohup batch_job_submit.pl $numberOfProcessors ./$scriptDir/intraAlnIdaV4.bat > intraAlnIdaV4.log\n";
	print FILEHDL "./$scriptDir/shiftIdaAln.bat > shiftIdaAln.log\n";
	print FILEHDL "./$scriptDir/pickIda.bat\n";
	print FILEHDL "./$scriptDir/cbnDocIdaV1.bat > cbnDocIdaV1.log\n";
	print FILEHDL "nohup batch_job_submit.pl $numberOfProcessors ./$scriptDir/interAlnIdaV1.bat > interAlnIdaV1.log\n";
	print FILEHDL "./$scriptDir/cbnAllDocIdaV1.bat > cbnAllDocIdaV1.log\n";
	print FILEHDL "./$scriptDir/avgIdaV1.bat > avgIdaV1.log\n";
	print FILEHDL "./$scriptDir/calcMwWeightIdaV1.bat > calcMwWeightIdaV1.log\n";
	print FILEHDL "./$scriptDir/weightedAvgIdaV1.bat > weightedAvgIdaV1.log\n";
	print FILEHDL "./$scriptDir/cleanUp.bat\n";

	close FILEHDL;

	&finishWriting($scriptFile);
	return 1;
}

#---------------------------
# Clean up script
#---------------------------
sub writeCleanUpScript {
	my ($scriptFile) = shift;;
	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!\n";

	#print "$scriptFile\n";
	my @pattern = ("*_ida_v2*.spi", "*_ida_v3*.spi", "*_ida_v4*.spi", "*.star", "doc*.spi", "*~");

	foreach (@pattern) {
		#print "$_\n";
		print FILEHDL "rm @pattern\n\n";
	}

	close FILEHDL;
	
	&finishWriting($scriptFile);

	return 1;
}

#---------------------------
# Change mod of script to +x & notify
#---------------------------
sub finishWriting {
	my ($scriptFile) = shift;
	chmod 0750, $scriptFile;
	print "\t$scriptFile created\n";
	return 1;
}

#----------------------------
# Delete file if exists
#----------------------------
sub deleteIfExists {
	my ($delFile) = shift;
	if (-e $delFile) {
		system("rm $delFile");
	}	
	return 1;
}
