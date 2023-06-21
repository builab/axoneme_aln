#!/usr/bin/perl -w
# Script to create all aa script
# HB 2008/08/07

use lib qw(/mol/ish/Data/programs/axoneme_aln/perl/lib);
use libaa;

$scriptName = "AA_SCRIPTS.PL";
$version = '1.2';
$vdate = '2008/10/27';

print "\#$scriptName v$version $vdate\n";



# Program default
$scriptDir = 'bat';
$docDir = 'doc';
$starDir = 'star';
$root = $root = $ENV{'AA_DIR'};
$templateDir = $root . '/template';

if ($#ARGV < 2 && $#ARGV != -1) {
	print "Usage: gen_aln_script.pl listFile paramFile scriptType\n";
	print "\tparamFile: e.g. chlamy.param\n";
	print "\tlistFile: e.g. list_chlamy.txt\n";
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
		if (($fileName =~ /\.param$/i) && !($fileName =~ /Ida\.param$/i)) {
			$paramFile = $fileName;
		}
		if (($fileName =~ /^list.*\.txt$/i) && !($fileName =~ /list.*ida_v1\.txt/i)) {
			$listFile = $fileName;
		}
	}
	closedir DIRFILEHDL;

	$listFile = getInput("List file", $listFile);
	$paramFile = getInput("Parameter file", $paramFile);

	print "Script Type [0]:\n";
	printf "\t%14s\n", "All[0]";
	printf "\t%14s %14s %14s %14s\n", "InitFit[1]", "UseFitStar[2]", "InitDoc[3]", "IntraAln[4]";
	printf "\t%14s %14s %14s %14s\n", "RoughAln[5]", "tfmRough[6]", "RefinedAln[7]", "tfmRefined[8]";
	printf "\t%14s %14s %14s\n", "CbnDoc[9]", "InterAln[10]", "CbnAllDoc[11]";
	printf "\t%14s %14s %14s\n", "CalcAvg[12]", "CalcWeight[13]", "WeightedAvg[14]";
	printf "\t%14s\n", "CleanUp[15]";
	printf "\t%14s\n", "Additional:\n";
	printf "\t%14s\n", "Supervised Classification[16]\n";
	print ": ";
	$scriptType = <>;
	chomp $scriptType;
}

%params = readParams($paramFile);

&createDir($scriptDir);

for ($scriptType) {
	/^0$/ && do {&writeTemplateToMScript("${scriptDir}/initFit.m", "${templateDir}/initFit.template", $paramFile); 
					&writeUseFittedStarScript("${scriptDir}/useFittedStar.bat", $listFile);
					&writeTemplateToMScript("${scriptDir}/initDoc.m", "${templateDir}/initDoc.template", $paramFile);
					&writeIntraScript("${scriptDir}/intraAln.bat" , $listFile, $paramFile);
					&writeTemplateToMScript("${scriptDir}/roughAln.m", "${templateDir}/roughAln.template", $paramFile);
					&writeXformScript("${scriptDir}/tfmRough.bat" , $listFile, '_', '_rough_', "$docDir/doc_rough_");
					&writeTemplateToMScript("${scriptDir}/refinedAln.m", "${templateDir}/refinedAln.template" , $paramFile);
					&writeXformScript("${scriptDir}/tfmRefined.bat" , $listFile, '_rough_', '_refined_', "$docDir/doc_refined_");
					&writeCbnScript("${scriptDir}/cbnDoc.bat" , $listFile, ["$docDir/doc_init_", "$docDir/doc_intra_", "$docDir/doc_rough_", "$docDir/doc_refined_", "$docDir/doc_cbn_"]);
					&writeInterScript("${scriptDir}/interAln.bat" , $listFile, $paramFile);
					&writeCbnScript("${scriptDir}/cbnAllDoc.bat" , $listFile, ["$docDir/doc_cbn_", "$docDir/doc_inter_", "$docDir/doc_total_"]);
					&writeAvgScript("${scriptDir}/avg.bat" , $listFile, $paramFile);
					&writeTemplateToMScript("${scriptDir}/calcMwWeight.m", "${templateDir}/calcMwWeight.template" , $paramFile);
					&writeTemplateToMScript("${scriptDir}/weightedAvg.m", "${templateDir}/weightedAvg.template" , $paramFile); 
					&writeOdaScript("$scriptDir/odaScript.bat", $paramFile);
					&writeCleanUpScript("${scriptDir}/cleanUp.bat");
					last;};
	/^1$/ && do {&writeTemplateToMScript("${scriptDir}/initFit.m", "${templateDir}/initFit.template", $paramFile); last;};
	/^2$/ && do {&writeUseFittedStarScript("${scriptDir}/useFittedStar.bat", $listFile); last;};
	/^3$/ && do {&writeTemplateToMScript("${scriptDir}/initDoc.m", "${templateDir}/initDoc.template", $paramFile); last;};
	/^4$/ && do {&writeIntraScript("${scriptDir}/intraAln.bat" , $listFile, $paramFile); last;};
	/^5$/ && do {&writeTemplateToMScript("${scriptDir}/roughAln.m", "${templateDir}/roughAln.template", $paramFile); last;};
	/^6$/ && do {&writeXformScript("${scriptDir}/tfmRough.bat" , $listFile, '_', '_rough_', "$docDir/doc_rough_"); last;};
	/^7$/ && do {&writeTemplateToMScript("${scriptDir}/refinedAln.m", "${templateDir}/refinedAln.template" , $paramFile); last;};
	/^8$/ && do {&writeXformScript("${scriptDir}/tfmRefined.bat" , $listFile, '_rough_', '_refined_', "$docDir/doc_refined_"); last;};
	/^9$/ && do {&writeCbnScript("${scriptDir}/cbnDoc.bat" , $listFile, ["$docDir/doc_init_", "$docDir/doc_intra_", "$docDir/doc_rough_", "$docDir/doc_refined_", "$docDir/doc_cbn_"]); last;};
	/^10$/ && do {&writeInterScript("${scriptDir}/interAln.bat" , $listFile, $paramFile); last;};	
	/^11$/ && do {&writeCbnScript("${scriptDir}/cbnAllDoc.bat" , $listFile, ["$docDir/doc_cbn_", "$docDir/doc_inter_", "$docDir/doc_total_"]); last;};
	/^12$/ && do {&writeAvgScript("${scriptDir}/avg.bat" , $listFile, $paramFile); last;}; 
	/^13$/ && do {&writeTemplateToMScript("${scriptDir}/calcMwWeight.m", "${templateDir}/calcMwWeight.template" , $paramFile); last;};
	/^14$/ && do {&writeTemplateToMScript("${scriptDir}/weightedAvg.m", "${templateDir}/weightedAvg.template" , $paramFile); last;};
	/^15$/ && do {&writeCleanUpScript("${scriptDir}/cleanUp.bat"); last;};
	/^16$/ && do {
		$params{"NumberOfReferences"} = getInput("Number Of References", $params{"NumberOfReferences"});
		$params{"IterationNo"} = getInput("Iteration No.", $params{"IterationNo"});
		&writeParams(\%params, $paramFile);
		&writeTemplateToMScript("${scriptDir}/multirefClassification.m", "${templateDir}/multirefClassification.template", $paramFile); last;
	};
	die "Unknown value for script type: $scriptType";
}


exit;


# -----------------------------------
# Write intra alignment script
# -----------------------------------
sub writeIntraScript {
	my ($scriptFile, $listFile, $paramFile) = @_;
	my %params = readParams($paramFile);
	my %list = parseList($listFile);
	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!";

	print FILEHDL "#Linking star and doc file\n";
	foreach (sort {$a cmp $b} (keys %list)) {
		print FILEHDL "ln -s $docDir/doc_init_$list{$_}.spi .\n";
		print FILEHDL "ln -s $starDir/$_.star\n";
	}	
	print FILEHDL "\n#Command\n";

	my $generalArg = ' -doc_output_prefix doc_intra_';
	$generalArg = $generalArg . ' -extract ' . $params{"ExtractedParticleRadius"};
	$generalArg = $generalArg . ' -bandpass ' . $params{"LowPassFreq"}. ',' . $params{"HighPassFreq"} . ',' . $params{"Sigma"};
	$generalArg = $generalArg . ' -box ' .  $params{"IntraCCLowerX"} . ',' . $params{"IntraCCUpperX"} . ',' . $params{"IntraCCLowerY"} . ',' . $params{"IntraCCUpperY"} . ',' . $params{"IntraCCLowerZ"} . ',' . $params{"IntraCCUpperZ"}; 
	$generalArg = $generalArg . ' -search_radius ' . $params{"IntraSearchRadius"};
	$generalArg = $generalArg . ' -numAvg ' . $params{"NumberOfParticlesToAverage"};

	my $specificArg = '';
	foreach (sort {$a cmp $b} (keys %list)) {
		$specificArg = ' -star ' . $_ . '.star';
		$specificArg = $specificArg . ' -doc_init doc_init_' . $list{$_} . '.spi';
		$cmd = 'mtb_auto_aln.pl' . $generalArg . $specificArg . ' ' . $list{$_};
		print FILEHDL "$cmd\n";
	}	
	close FILEHDL;
	&finishWriting($scriptFile);
	return 1;
}

# -----------------------------------
# Write inter alignment script
# -----------------------------------
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

	print FILEHDL "\n#Command\n";
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
		$cmd = 'mtb_auto_aln.pl' . $generalArg . $specificArg . ' ' . $list{$_};
		print FILEHDL "$cmd\n";
	}	
	close FILEHDL;
	&finishWriting($scriptFile);
	return 1;
}

#---------------------------
# Average script
#---------------------------
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

	print FILEHDL "\n#Command\n";

	my $generalArg = ' -align 0';
	$generalArg = $generalArg . ' -extract ' . $params{"ExtractedParticleRadius"};
	$generalArg = $generalArg . ' -lower_limit ' . $params{"LowerLimit"};

	my $specificArg = '';
	foreach (sort {$a cmp $b} (keys %list)) {
		$specificArg = ' -star ' . $_ . '.star';
		$specificArg = $specificArg . ' -doc_init doc_total_' . $list{$_} . '.spi';
		$cmd = 'mtb_auto_aln.pl' . $generalArg . $specificArg . ' ' . $list{$_};
		print FILEHDL "$cmd\n";
	}	

	my $output = $params{"AverageFile"};
	$output =~ s/\.spi$//i;

	my $avgCmd = 'spider_avg.pl -output ' . $output . ' -list ' . $listFile;

	print FILEHDL "#Sum\n$avgCmd\n";
	close FILEHDL;
	&finishWriting($scriptFile);

	return 1;
}

#---------------------------
# Write transform script
#---------------------------
sub writeXformScript {
	my ($scriptFile, $listFile, $inputPattern, $outputPattern, $docPattern) = @_;
	my %list = parseList($listFile);
	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!";

	foreach (sort {$a cmp $b} (values %list)) {		
		$_ =~ /^(.*)_(\d\d\d)/i;
		$cmd = 'tfm_series.pl -u ' . $1 . $inputPattern . ' ' . $2 . ' ' . $2 . ' ' . $1 . $outputPattern . ' ' . $docPattern . $_ . '.spi';
		print FILEHDL "$cmd\n";
	}	
	close FILEHDL;
	&finishWriting($scriptFile);
	return 1;
}

#---------------------------
# Combine doc scripts
#---------------------------
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
		my $cmd = 'combine_xform_doc.pl ';
		foreach my $docPrefix (@listDocPrefix) {
			$cmd = $cmd . $docPrefix . $avgFile . '.spi ';
		}
		print FILEHDL "$cmd\n";
	}	
	close FILEHDL;
	&finishWriting($scriptFile);
	return 1;
}

#---------------------------
# Write template to MScript
#---------------------------
sub writeTemplateToMScript {
	my ($scriptFile, $templateFile, $paramFile) = @_;

	my %params = readParams($paramFile);

	#print Dumper(%params); # DEBUG
	my $batchFile = $scriptFile;
	$batchFile =~ s/\.m$/\.bat/i;
	$logFile = $batchFile;
	$logFile =~ s/^.*\/(.*)\.bat$/$1\.log/g;

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

#---------------------------
# Use Fitted Star Script
#---------------------------
sub writeUseFittedStarScript {
	my ($scriptFile, $listFile) = @_;
	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!\n";
	open (LSTHDL, "$listFile") || die "Cannot open $listFile. $!\n";
	
	while (<LSTHDL>) {
		chomp;
		if (/\#/) { next; }
		@line = split(' ', $_);
		$starFile = $starDir . '/' . $line[1] . '.star';
		$fittedFile = $starFile;
		$fittedFile =~ s/\.star$/_fitted\.star/i;
		print FILEHDL "mv $starFile $starFile.bak\n";
		print FILEHDL "mv $fittedFile $starFile\n";
	}
	
	close FILEHDL;
	close LSTHDL;

	&finishWriting($scriptFile);

	return 1;
}

#---------------------------
# Clean up script
#---------------------------
sub writeCleanUpScript {
	my ($scriptFile) = shift;
	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!\n";

	#print "$scriptFile\n";
	my @pattern = ("*_rough_*.spi", "*_refined_*.spi", "*.star", "doc*.spi", "*~");

	print FILEHDL "rm @pattern\n\n";
	close FILEHDL;
	
	&finishWriting($scriptFile);

	return 1;
}

#---------------------------
# Write script for 1st part of alignment
#---------------------------
sub writeOdaScript {
	my ($scriptFile, $paramFile) = @_;
	
	my %params = readParams($paramFile);
	my $numberOfProcessors = $params{"NumberOfProcessors"};
	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!";

	print FILEHDL "./$scriptDir/initFit.bat\n";
	print FILEHDL "./$scriptDir/useFittedStar.bat\n";
	print FILEHDL "./$scriptDir/initDoc.bat\n";
	print FILEHDL "nohup batch_job_submit.pl $numberOfProcessors ./$scriptDir/intraAln.bat > intraAln.log\n";
	print FILEHDL "./$scriptDir/roughAln.bat\n";
	print FILEHDL "./$scriptDir/tfmRough.bat\n";
	print FILEHDL "./$scriptDir/refinedAln.bat\n";
	print FILEHDL "./$scriptDir/cbnDoc.bat > cbnDoc.log\n";
	print FILEHDL "nohup batch_job_submit.pl $numberOfProcessors ./$scriptDir/interAln.bat > interAln.log\n";
	print FILEHDL "./$scriptDir/cbnAllDoc.bat > cbnAllDoc.log\n";
	print FILEHDL "nohup batch_job_submit.pl $numberOfProcessors ./$scriptDir/avg.bat > avg.log\n";
	print FILEHDL "./$scriptDir/calcMwWeight.bat\n";
	print FILEHDL "./$scriptDir/weightedAvg.bat\n";
	print FILEHDL "./$scriptDir/cleanUp.bat\n";
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
