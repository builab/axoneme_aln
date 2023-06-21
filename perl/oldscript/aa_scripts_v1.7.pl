#!/usr/bin/perl -w
# Script to create all aa script
# HB 2008/08/07
# v1.3: add calcMwClassAvg & weightedClassAvg
# v1.4: add name prefix for each script
# v1.5: add roughAlnMirror, add verifyAln
# v1.6: add axon_reorder.pl
# v1.7: reading doc & star file directly from its native dir
#	add printMenu	

use libaa;
use Data::Dumper;

$scriptName = "AA_SCRIPTS.PL";
$version = '1.7';
$vdate = '2010/06/01';

print "\#$scriptName v$version $vdate\n";



# ------ Program default -----------------
$scriptDir = 'bat';
$docDir = 'doc';
$starDir = 'star';
$root = $ENV{'AA_DIR'};
$templateDir = $root . '/template';
$mtb_auto_aln_script = 'mtb_auto_aln.pl';
$spider_avg_script = 'spider_avg.pl';
# ----------------------------------------

%mainMenu = (	1 => "InitFit", 
		2 => "UseFitStar",
		3 => "InitDoc",
		4 => "IntraAln",
		5 => "RoughAln",
		6 => "XformRough",
		7 => "RefineAln",
		8 => "XformRefined",
		9 => "CbnDoc",
		10 => "InterAln",
		11 => "CbnAllDoc",
		12 => "VerifyAln",
		13 => "CalcAvg",
		14 => "CalcWeight",
		15 => "WeightedAvg",
		16 => "CleanUp"
		);
%addMenu = (	17 => "Supervised Classification",
		18 => "Reorder Axoneme",
		19 => "Redraw Model" );
	


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
$isNotDone = 1;
	
if ($#ARGV == 2) {
	$listFile = $ARGV[0];
	$paramFile = $ARGV[1];
	$scriptType = $ARGV[2];
	$isNotDone = 0;
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

	&printMenu(\%mainMenu, \%addMenu);

}

$projName = $paramFile;
$projName =~ s/\.param//i;

%params = readParams($paramFile);

&createDir($scriptDir);

#print Dumper(%params);

$msg = '';
do {
	if ($isNotDone) {
		print "$msg: ";
		$scriptType = <>;
		chomp $scriptType;	
	}	
	$msg = 'New script input (type \'done\' to quit)';
	
for ($scriptType) {
	/^0$/ && do {&writeTemplateToMScript("${scriptDir}/${projName}_initFit.m", "${templateDir}/initFit.template", $paramFile); 
					&writeUseFittedStarScript("${scriptDir}/${projName}_useFittedStar.bat", $listFile);
					&writeTemplateToMScript("${scriptDir}/${projName}_initDoc.m", "${templateDir}/initDoc.template", $paramFile);
					&writeIntraScript("${scriptDir}/${projName}_intraAln.bat" , $listFile, $paramFile);
					
					if (defined ($params{"SearchDirection"}) && ($params{"SearchDirection"}==1)) {					
						&writeTemplateToMScript("${scriptDir}/${projName}_roughAln.m", "${templateDir}/roughAlnMirror.template", $paramFile);
					} else {
						&writeTemplateToMScript("${scriptDir}/${projName}_roughAln.m", "${templateDir}/roughAln.template", $paramFile);
					}

					&writeXformScript("${scriptDir}/${projName}_tfmRough.bat" , $listFile, '_', '_rough_', "$docDir/doc_rough_");
					&writeTemplateToMScript("${scriptDir}/${projName}_refinedAln.m", "${templateDir}/refinedAln.template" , $paramFile);
					&writeXformScript("${scriptDir}/${projName}_tfmRefined.bat" , $listFile, '_rough_', '_refined_', "$docDir/doc_refined_");
					&writeCbnScript("${scriptDir}/${projName}_cbnDoc.bat" , $listFile, ["$docDir/doc_init_", "$docDir/doc_intra_", "$docDir/doc_rough_", "$docDir/doc_refined_", "$docDir/doc_cbn_"]);
					&writeInterScript("${scriptDir}/${projName}_interAln.bat" , $listFile, $paramFile);
					&writeCbnScript("${scriptDir}/${projName}_cbnAllDoc.bat" , $listFile, ["$docDir/doc_cbn_", "$docDir/doc_inter_", "$docDir/doc_total_"]);
					&writeTemplateToMScript("${scriptDir}/${projName}_verifyAln.m", "${templateDir}/verifyAln.template" , $paramFile);
					&writeAvgScript("${scriptDir}/${projName}_avg.bat" , $listFile, $paramFile);
					&writeTemplateToMScript("${scriptDir}/${projName}_calcMwWeight.m", "${templateDir}/calcMwWeight.template" , $paramFile);
					&writeTemplateToMScript("${scriptDir}/${projName}_weightedAvg.m", "${templateDir}/weightedAvg.template" , $paramFile); 
					&writeOdaScript("$scriptDir/${projName}_odaScript.bat", $paramFile);
					&writeCleanUpScript("${scriptDir}/${projName}_cleanUp.bat");
					$isNotDone = 0;
					last;};
	/^1$/ && do {&writeTemplateToMScript("${scriptDir}/${projName}_initFit.m", "${templateDir}/initFit.template", $paramFile); last;};
	/^2$/ && do {&writeUseFittedStarScript("${scriptDir}/${projName}_useFittedStar.bat", $listFile); last;};
	/^3$/ && do {&writeTemplateToMScript("${scriptDir}/${projName}_initDoc.m", "${templateDir}/initDoc.template", $paramFile); last;};
	/^4$/ && do {&writeIntraScript("${scriptDir}/${projName}_intraAln.bat" , $listFile, $paramFile); last;};
	/^5$/ && do {	if (defined ($params{"SearchDirection"}) && ($params{"SearchDirection"}==1)) {					
						&writeTemplateToMScript("${scriptDir}/${projName}_roughAln.m", "${templateDir}/roughAlnMirror.template", $paramFile);
					} else {
						&writeTemplateToMScript("${scriptDir}/${projName}_roughAln.m", "${templateDir}/roughAln.template", $paramFile);
					}
					last;
				};
	/^6$/ && do {&writeXformScript("${scriptDir}/${projName}_tfmRough.bat" , $listFile, '_', '_rough_', "$docDir/doc_rough_"); last;};
	/^7$/ && do {&writeTemplateToMScript("${scriptDir}/${projName}_refinedAln.m", "${templateDir}/refinedAln.template" , $paramFile); last;};
	/^8$/ && do {&writeXformScript("${scriptDir}/${projName}_tfmRefined.bat" , $listFile, '_rough_', '_refined_', "$docDir/doc_refined_"); last;};
	/^9$/ && do {&writeCbnScript("${scriptDir}/${projName}_cbnDoc.bat" , $listFile, ["$docDir/doc_init_", "$docDir/doc_intra_", "$docDir/doc_rough_", "$docDir/doc_refined_", "$docDir/doc_cbn_"]); last;};
	/^10$/ && do {&writeInterScript("${scriptDir}/${projName}_interAln.bat" , $listFile, $paramFile); last;};	
	/^11$/ && do {&writeCbnScript("${scriptDir}/${projName}_cbnAllDoc.bat" , $listFile, ["$docDir/doc_cbn_", "$docDir/doc_inter_", "$docDir/doc_total_"]); last;};
	/^12$/ && do {&writeTemplateToMScript("${scriptDir}/${projName}_verifyAln.m", "${templateDir}/verifyAln.template" , $paramFile); last;};
	/^13$/ && do {&writeAvgScript("${scriptDir}/${projName}_avg.bat" , $listFile, $paramFile); last;}; 	
	/^14$/ && do {&writeTemplateToMScript("${scriptDir}/${projName}_calcMwWeight.m", "${templateDir}/calcMwWeight.template" , $paramFile); last;};
	/^15$/ && do {&writeTemplateToMScript("${scriptDir}/${projName}_weightedAvg.m", "${templateDir}/weightedAvg.template" , $paramFile); last;};
	/^16$/ && do {&writeCleanUpScript("${scriptDir}/${projName}_cleanUp.bat"); last;};
	/^17$/ && do {
		$params{"NumberOfReferences"} = getInput("Number Of References", $params{"NumberOfReferences"});
		$params{"IterationNo"} = getInput("Iteration No.", $params{"IterationNo"});
		$iter = $params{"IterationNo"};
		&writeParams(\%params, $paramFile);
		&writeTemplateToMScript("${scriptDir}/${projName}_multirefClassification_iter${iter}.m", "${templateDir}/multirefClassification.template", $paramFile);
		&writeTemplateToMScript("${scriptDir}/${projName}_plotClassificationResult_iter${iter}.m", "${templateDir}/plotClassificationResult.template", $paramFile);
		last;
	};		
	/^18$/ && do {&writeReorderScript("${scriptDir}/${projName}_axonReorder.bat", $listFile, 1); last;};
	/^19$/ && do {
		&writeTemplateToMScript("${scriptDir}/${projName}_redrawModel.m", "${templateDir}/redrawModel.template", $paramFile);
			last;};
	/^done$/ && do {
		$isNotDone = 0;
		last;
	};
	$msg = 'reinput correctly (\'done\' to stop)';	
}
} while ($isNotDone);

exit;


# -----------------------------------
# Write intra alignment script
# -----------------------------------
sub writeIntraScript {
	my ($scriptFile, $listFile, $paramFile) = @_;
	my %params = readParams($paramFile);
	my %list = parseList($listFile);
	open (FILEHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!";

	print FILEHDL "#Intra Aln Command\n";
	my $generalArg = ' -doc_output_prefix ' . $docDir . '/doc_intra_';
	$generalArg = $generalArg . ' -extract ' . $params{"ExtractedParticleRadius"};
	$generalArg = $generalArg . ' -bandpass ' . $params{"LowPassFreq"}. ',' . $params{"HighPassFreq"} . ',' . $params{"Sigma"};
	$generalArg = $generalArg . ' -box ' .  $params{"IntraCCLowerX"} . ',' . $params{"IntraCCUpperX"} . ',' . $params{"IntraCCLowerY"} . ',' . $params{"IntraCCUpperY"} . ',' . $params{"IntraCCLowerZ"} . ',' . $params{"IntraCCUpperZ"}; 
	$generalArg = $generalArg . ' -search_radius ' . $params{"IntraSearchRadius"};
	$generalArg = $generalArg . ' -numAvg ' . $params{"NumberOfParticlesToAverage"};
	if ((defined $params{"IntraAlnIter"}) && ($params{"IntraAlnIter"} > 1)) {
		$generalArg = $generalArg . ' -iter ' . $params{"IntraAlnIter"};
	}

	my $specificArg = '';
	foreach (sort {$a cmp $b} (keys %list)) {
		$specificArg = ' -star ' . $starDir . '/' . $_ . '.star';
		$specificArg = $specificArg . ' -doc_init ' . $docDir . '/doc_init_' . $list{$_} . '.spi';
		$cmd = $mtb_auto_aln_script . ' ' . $generalArg . $specificArg . ' ' . $list{$_};
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

	print FILEHDL "\n#Inter Aln Command\n";
	my $generalArg = ' -doc_output_prefix ' . $docDir . '/doc_inter_';
	$generalArg = $generalArg . ' -extract ' . $params{"ExtractedParticleRadius"};
	$generalArg = $generalArg . ' -bandpass ' . $params{"LowPassFreq"}. ',' . $params{"HighPassFreq"} . ',' . $params{"Sigma"};
	$generalArg = $generalArg . ' -box ' .  $params{"InterCCLowerX"} . ',' . $params{"InterCCUpperX"} . ',' . $params{"InterCCLowerY"} . ',' . $params{"InterCCUpperY"} . ',' . $params{"InterCCLowerZ"} . ',' . $params{"InterCCUpperZ"}; 
	$generalArg = $generalArg . ' -ref ' . $params{"Reference"};
	$generalArg = $generalArg . ' -search_radius ' . $params{"InterSearchRadius"};

	my $specificArg = '';
	foreach (sort {$a cmp $b} (keys %list)) {
		$specificArg = ' -star ' . $starDir . '/' . $_ . '.star';
		$specificArg = $specificArg . ' -doc_init ' . $docDir . '/doc_cbn_' . $list{$_}  . '.spi';
		$cmd = $mtb_auto_aln_script .' ' . $generalArg . $specificArg . ' ' . $list{$_};
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

	print FILEHDL "#Average Command\n";

	my $generalArg = ' -align 0';
	$generalArg = $generalArg . ' -extract ' . $params{"ExtractedParticleRadius"};
	$generalArg = $generalArg . ' -lower_limit ' . $params{"LowerLimit"};

	my $specificArg = '';
	foreach (sort {$a cmp $b} (keys %list)) {
		$specificArg = ' -star ' . $starDir . '/' . $_ . '.star';
		$specificArg = $specificArg . ' -doc_init ' . $docDir . '/doc_total_' . $list{$_} . '.spi';
		$cmd = $mtb_auto_aln_script .' ' . $generalArg . $specificArg . ' ' . $list{$_};
		print FILEHDL "$cmd\n";
	}	

	my $output = $params{"AverageFile"};
	$output =~ s/\.spi$//i;

	my $avgCmd = $spider_avg_script . ' -output ' . $output . ' -list ' . $listFile;
	print FILEHDL "$avgCmd\n";	

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

	foreach my $avgFile (sort {$a cmp $b} (values %list)) {				
		my $cmd = 'combine_xform_doc.pl ';
		foreach my $docPrefix (@{$listDocPrefix}) {
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
	my @pattern = ("*_rough_*.spi", "*_refined_*.spi", "*~", "result.soc.*");
	my @dirpattern = ("*_00?_[1-9]*[0-9]");

	print FILEHDL "rm @pattern\n\n";
	print FILEHDL "rm -R @dirpattern";
	close FILEHDL;
	
	&finishWriting($scriptFile);

	return 1;
}

#---------------------------
# Axon reorder script
#---------------------------
sub writeReorderScript {
	my ($scriptFile, $listFile, $isOdaPrj) = @_;
	my %reorderList = ();

	open(FILEHDL, "$listFile") || die "Cannot open $listFile\n";
	my $flagName = '';
	my $prevFlagName = '';

	while (<FILEHDL>) {
		if (/#/i) { next; };
		chomp;
		my @line = split(' ', $_);
		$flagName = $line[0];
		$flagName =~ s/(_ida_v1)?_00\d//i;
		if ($flagName eq $prevFlagName) {
			next;
		}
		$prevFlagName = $flagName;
		my $doubletOne = getInput("Doublet number of doublet 1 of $flagName", 1);
		$reorderList{$flagName} = $doubletOne;					
	}
	close FILEHDL;

	open (SCRIPTHDL, ">$scriptFile") || die "Cannot open $scriptFile.\n";
	foreach (sort {$a cmp $b} keys(%reorderList)) {
		print SCRIPTHDL "axon_reorder.pl $_ $reorderList{$_} $isOdaPrj\n";		
	}
	close SCRIPTHDL;
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

	my	$projName = $paramFile;
	$projName =~ s/\.param//i;

	print FILEHDL "./$scriptDir/${projName}_initFit.bat\n";
	print FILEHDL "./$scriptDir/${projName}_useFittedStar.bat\n";
	print FILEHDL "./$scriptDir/${projName}_initDoc.bat\n";
	print FILEHDL "nohup batch_job_submit.pl $numberOfProcessors ./$scriptDir/${projName}_intraAln.bat > ${projName}_intraAln.log\n";
	print FILEHDL "./$scriptDir/${projName}_roughAln.bat\n";
	print FILEHDL "./$scriptDir/${projName}_tfmRough.bat\n";
	print FILEHDL "./$scriptDir/${projName}_refinedAln.bat\n";
	print FILEHDL "./$scriptDir/${projName}_cbnDoc.bat > ${projName}_cbnDoc.log\n";
	print FILEHDL "nohup batch_job_submit.pl $numberOfProcessors ./$scriptDir/${projName}_interAln.bat > ${projName}_interAln.log\n";
	print FILEHDL "./$scriptDir/${projName}_cbnAllDoc.bat > ${projName}_cbnAllDoc.log\n";
	print FILEHDL "./$scriptDir/${projName}_verifyAln.bat > ${projName}_verifyAln.log\n";
	print FILEHDL "nohup batch_job_submit.pl $numberOfProcessors ./$scriptDir/${projName}_avg.bat > ${projName}_avg.log\n";
	print FILEHDL "./$scriptDir/${projName}_calcMwWeight.bat\n";
	print FILEHDL "./$scriptDir/${projName}_weightedAvg.bat\n";
	print FILEHDL "./$scriptDir/${projName}_cleanUp.bat\n";
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
