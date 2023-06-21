#!/usr/bin/perl -w
# Script to create AA project
# HB 2008/08/07
use Data::Dumper;
$scriptName = 'AA_STARTUP.PL';
$version = '1.0';
$vdate = '2008/08/12';

print "#$scriptName v$version $vdate\n";

# ------------ DEFAULT LOCATION ----------------------
$starDir = 'star';
$scriptDir = 'bat';
$docDir = 'doc';
$graphDir = 'graph';
# ------------ END DEFAULT ---------------------------

$root = $ENV{'AA_DIR'};
$defaultParamsFile = $root . '/default.param';

%params = readParams($defaultParamsFile);

$projName = getInput("Project name e.g. chlamy", "");
$flagDirectFile = getInput("Flagella direction file", 'flaDirect.txt');
$params{"TiltAngleFile"} = getInput("Tilt Angle File", "ta_${projName}.txt");
$params{"PixelSize"}= getInput("PixelSize (nm)", $params{"PixelSize"});
$params{"Reference"} = getInput("Reference File", "${projName}_ref_masked.spi");
$params{"LowResReference"} = getInput("Low Resolution Reference File", "${projName}_ref_low.spi");
$params{"Mask"} = getInput("Mask File", "${projName}_3dmask.spi");
$params{"NumberOfProcessors"} = getInput("Number of processors used:", $params{"NumberOfProcessors"});

# Update parameters
$listFile = 'list_' . $projName . '.txt';

$params{"ListFile"}=$listFile;
$params{"AverageFile"}= $projName . '_avg.spi';
$params{"WeightFile"}= 'weight_' . $projName . '.spi';
$params{"CorrectedAverageFile"} = $projName . '_avg_cr.spi';


$paramFile = $projName . '.param';

if (!writeParams(\%params, $paramFile)) {
	&terminated();
}

# Checking star files
print "Check star files\n";
@starDirContents = <$starDir/*.star>;

$doContinue = 1;
foreach (sort {$a cmp $b} @starDirContents) {
		if (/_\d\.star/i) {
			print "\t$_ ... ";
			if (checkStarFile($_)) {
				print "OK\n";
			} else {
				$doContinue = 0;
			}
		}
}
print "Done!\n";

if (!$doContinue) {
	$doContinue = getInput("WARNING: Some star files are not configured properly.\nDo you want to continue? (Yes = 1, No = 0)", "0");
}

if (!$doContinue) {
	&notifyError("");
}

# Linking startup.m
print "Linking startup.m ...\n";
system("rm startup.m");
$cmd = 'ln -s ' . $root . '/matlab/startup.m .';
print "\t$cmd\n";
if (system($cmd)) {
	print "Done!\n";
}

# Create directories
print "Create directories\n";
if (!createDir($docDir, $scriptDir, $graphDir)) {
	&notifyError("Error creating directories!");
}
print "Done!\n";

# Create List File
print "Generate list file $listFile ..\n";
$doOverwrite = 1;
if (-e $listFile) {
	$doOverwrite = getInput("\"$listFile\" exists. Overwrite (Yes=1; No=0)", "0");
}

if ($doOverwrite) {
	if (!createListFile($flagDirectFile, $starDir, $listFile)) {
		&notifyError("Error creating list file!");
	}
}
print "Done!\n";

# Create script
print "Generate scripts ..\n";
my $cmd = "aa_scripts.pl $listFile $paramFile 0";
system($cmd);
print "Done!\n";


print "\nThat's all you need!!\n";

sub createListFile {
	my ($flagDirectFile, $starDir, $listFile) = @_;

	eval {
		open(FLAGHDL, $flagDirectFile) || die "Cannot open $flagDirectFile. $!";
		open(LSTHDL, ">$listFile") || die "Cannot create $listFile. $!";
	};
	if ($@) { print $@; return 0;}
	
	my %flagDirect = ();
	while (<FLAGHDL>) {
		chomp;
		my @line = split(' ', $_);
		$flagDirect{$line[0]} = $line[1];				
	}
	close FLAGHDL;

	# print Dumper(%flagDirect); # DEBUG
	@starDirContents = <$starDir/*.star>;

	# Write time
    my $currtime = time();
    my @timelist = localtime($currtime);
    my $year = $timelist[5] + 1900;
	my $month = $timelist[4]+1;
	print LSTHDL "\#$timelist[3]-$month-$year  $timelist[2]:$timelist[1]:$timelist[0]\n";

	foreach my $fileName(sort {$a cmp $b} @starDirContents) {
			if ($fileName =~ /^.*\/(.*)_(\d)\.star$/i) {
				my $avgFile = $1 . '_00' . $2;
				my $starFile = $1 . '_' . $2;		
				if (!defined($flagDirect{$1})) {
					print "ERROR: Undefined flagella direction for $1\n";
					return 0;
				}
				$line = sprintf("%-12s %10s %4s\n", $avgFile, $starFile, $flagDirect{$1});
				printf "\t$line";
				printf LSTHDL $line;
			} else {
				print "Star file $fileName in wrong name format. Example of correct format name: \"fla_10_1.star\" or \"fla10_1.star\"\n";
				close LSTHDL;
				system("rm", $listFile);
				return 0;
			}			
	}

	print "Done!\n";
	close LSTHDL;
	return 1;
}

sub createDir {
	my ($docDir, $scriptDir, $graphDir) = @_;
	eval {
	if (-d $docDir) {
		print "\t$docDir already exists\n";
	} else {
		print "\tmkdir $docDir\n";
		mkdir ($docDir) || die "Cannot create $docDir. $!\n";
	} 
	if (-d $scriptDir) {
		print "\t$scriptDir already exists\n";
	} else {
		print "\tmkdir $scriptDir\n";
		mkdir ($scriptDir) || die "Cannot create $scriptDir. $!\n";
	}
	if (-d $graphDir) {
		print "\t$graphDir already exists\n";
	} else {
		print "\tmkdir $graphDir\n";
		mkdir ($graphDir) || die "Cannot create $graphDir. $!\n";
	}
	};

	if ($@) { print $@; return 0;};
	return 1;
}

sub readParams {
	my ($paramFile) = shift;
	eval {
		open(FILEHDL, "$paramFile") || die "Cannot open $paramFile. $!\n";
	};

	if ($@) { print $@; return 0};
	#print "Parsing $paramFile\n";
	my %params = ();
	while (<FILEHDL>) {
		chomp;
		if (/^\#/i) {
			next;
		}
		if (/^(\S*)=(\S*)$/) {
			$params{$1} = $2;
			#printf "\t%20s   %s\n", $1, $2;
		}
	}
	close FILEHDL;
	return %params;	
}

sub writeParams {
	my ($params, $paramFile) = @_;
	%params = %{$params};
	
	eval {
		open(FILEHDL, ">$paramFile") || die "Cannot open $paramFile. $!\n"; 
	};

	if ($@) { print $@; return 0;}

	# Write time
    my $currtime = time();
    my @timelist = localtime($currtime);
    my $year = $timelist[5] + 1900;
	my $month = $timelist[4]+1;
	print FILEHDL "\#$timelist[3]-$month-$year  $timelist[2]:$timelist[1]:$timelist[0] by Axoneme_aln v$version\n";

	foreach my $key (sort {$a cmp $b} (keys %params)) {
		print FILEHDL "$key=$params{$key}\n";
	}		
	close FILEHDL;
	return 1;
}

sub checkStarFile {
	my ($starFile) = shift;
	eval {
		open (FILEHDL, $starFile) || die "Cannot open $starFile. $!\n";
	};
	if ($@) { print $@; return 0;};
	while (<FILEHDL>) {
		chomp;
		if (/micrograph\.file_name\s+(\S+)/i) {
			if (!(-e $1)) {
				print "$1 not exists\n";
				close FILEHDL;
				return 0;
			}
		}
		if (/micrograph_particle\.file_name\s+(\S+\.pif)/i) {
			close FILEHDL;
			return 1;
		}			
	}
	print "Error at _micrograph_particle.file_name\n";
	return 0;
}

sub getInput {
	my ($question, $defaultAnswer) = @_;
	print "$question [$defaultAnswer]: ";
	chomp (my $input = <>);
	if ($input =~ /^\S+$/i) {
		return $input;
	}
	return $defaultAnswer;
}

sub notifyError {
	my ($errorMsg) = shift;
	print "$errorMsg\n";
	print "Program terminated!!!\n";
	exit (1);
}	
