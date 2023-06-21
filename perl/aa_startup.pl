#!/usr/bin/perl
# Script to create AA project
# HB 2008/08/07
# v1.2: Add option without flaDirect.txt, Add persistence ask for input file1

use Data::Dumper;
use Bstar1_6;
use libaa;

$scriptName = 'AA_STARTUP.PL';
$version = '1.7';
$vdate = '2010/06/18';

print "#$scriptName v$version $vdate\n";



# ------------ DEFAULT LOCATION ----------------------
$starDir = 'star';
$scriptDir = 'bat';
$docDir = 'doc';
$graphDir = 'graph';
$paramDir = 'params';
$aa_script = 'aa_scripts.pl';
# ------------ END DEFAULT ---------------------------

$root = $ENV{'AA_DIR'};
$defaultParamsFile = $root . '/'. $paramDir . '/default.param';

%params = readParams($defaultParamsFile);

$projName = getInput("Project name e.g. chlamy", "");

$doWithoutDirection = 0;

while (1) { 
	$flagDirectFile = getInput("Flagella direction file", 'flaDirect.txt');
	if (!(-e $flagDirectFile)) {
		$doWithoutDirection = getInput("$flagDirectFile does NOT exist!!!. Go on without the file (Yes=1, No=0)", 1);
		if ($doWithoutDirection) {
			$flagDirectFile = '';
			last;
		}	
	} else {
		last;
	}	
}

$params{"SearchDirection"} = $doWithoutDirection;
$params{"TiltAngleFile"} = getInputPersistence("Tilt Angle File", "ta_${projName}.txt");
$params{"PixelSize"}= getInput("PixelSize (nm)", $params{"PixelSize"});
$params{"Reference"} = getInput("Reference File", "${projName}_ref_masked.spi");
$params{"Mask"} = getInput("Mask File", "${projName}_3dmask.spi");
$params{"NumberOfProcessors"} = getInput("Number of processors used:", $params{"NumberOfProcessors"});

# Update parameters
$listFile = 'list_' . $projName . '.txt';

$params{"ListFile"}=$listFile;
$params{"AverageFile"}= $projName . '_avg.spi';
$params{"WeightFile"}= 'weight_' . $projName . '_avg.spi';
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
foreach (($docDir, $scriptDir, $graphDir)) {
	if (!createDir($_)) {
		&notifyError("Error creating directories!");		
	}
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
my $cmd = $aa_script . " $listFile $paramFile 0";
system($cmd);
print "Done!\n";


print "\nThat's all you need!!\n";


# -----------------------------------
# create List file
# -----------------------------------
sub createListFile {
	my ($flagDirectFile, $starDir, $listFile) = @_;

	my $doWithoutDirection = 0;
	if ($flagDirectFile eq '') {
		$doWithoutDirection = 1;
	}
	eval {
		if (!$doWithoutDirection) {
			open(FLAGHDL, $flagDirectFile) || die "Cannot open $flagDirectFile. $!";
		}	
		open(LSTHDL, ">$listFile") || die "Cannot create $listFile. $!";
	};
	if ($@) { print $@; return 0;}

	my %flagDirect = ();	
	if (!$doWithoutDirection) {	

		while (<FLAGHDL>) {
			chomp;
			if (/^\s*$/i) { next;}
			my @line = split(' ', $_);
			$flagDirect{$line[0]} = $line[1];				
		}
		close FLAGHDL;
	}

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

				if ($doWithoutDirection) {			
					$line = sprintf("%-12s %10s %4s\n", $avgFile, $starFile, 0);
				} else {
					if (!defined($flagDirect{$1})) {
						print "ERROR: Undefined flagella direction for $1\n";
						return 0;
					}
					$line = sprintf("%-12s %10s %4s\n", $avgFile, $starFile, $flagDirect{$1});
				}
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


# -----------------------------------
# check Star files to see if ok
# -----------------------------------
sub checkStarFile {
	my ($starFile) = shift;
	my $star = Bstar->new();
	$star->read_bstar($starFile);
	my $tomo = $star->get_header_item('_map.3D_reconstruction.file_name');
	if (-e $tomo) {
		return 1;
	}
	print "$tomo not exists\n";
	return 0;
}

