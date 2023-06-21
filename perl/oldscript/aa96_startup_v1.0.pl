#!/usr/bin/perl -w
# Script to create AA project
# HB 2008/08/07
use Data::Dumper;
$scriptName = 'AA96_STARTUP.PL';
$version = '1.0';
$vdate = '2008/08/12';

print "#$scriptName v$version $vdate\n";

# ------------ DEFAULT LOCATION ----------------------
#$starDir = 'star';
$scriptDir = 'bat';
$docDir = 'doc';
$graphDir = 'graph';
# ------------ END DEFAULT ---------------------------

$root = $ENV{'AA_DIR'};
$defaultIdaParamsFile = $root . '/defaultIda.param';
%idaParams = readParams($defaultIdaParamsFile);

@paramFiles = <*.param>;

$oldParamFile = '';
foreach (@paramFiles) {
	if (/[^Ida].*\.param$/i) {
		$oldParamFile = $_;
		last;
	}		
}

$oldParamFile = getInput("24nm project file (e.g.: chlamy.param)", $oldParamFile);
$projName = $oldParamFile;
$projName =~ s/\.param//g;
$idaParams{"LowResReference"} = getInput("Low Resolution Reference File", $idaParams{"LowResReference"});
$idaParams{"Mask"} = getInput("Mask File", $idaParams{"Mask"});

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
$idaParams{"IdaPeriod"}=4*$params{"Period"};
$idaParams{"TiltAngleFile"}=$params{"TiltAngleFile"};

print "Create new param ...\n";
$idaParams{"ListFile"}= 'list_' . $projName . '_ida_v1.txt';
$idaParams{"AverageFile"}= $projName .  '_ida_v1_avg.spi';
$idaParams{"WeightFile"}= 'weight_' . $projName . '_ida_v1.spi';
$idaParams{"CorrectedAverageFile"} = $projName .  '_ida_v1_avg_cr.spi';
writeParams(\%idaParams, $paramFile);
print "\t${projName}Ida.param created\n";
print "Done!\n";

# Create script
print "Generate scripts ..\n";
my $cmd = "aa96_scripts.pl $listIdaFile $paramFile 0";
system($cmd);
print "Done!\n";

print "\nThat's all you need!!\n";

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

sub terminate {
	print "Program terminated!!!\n";
	exit(1);
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
				$_ =~ s/^(.*)_(\d\d\d\s+)(\S+)(\s+\d)/$1_ida_v1_$2$3ida_v1$4/i;
				print LSTHDL 	$_;
		}
	}
	close LSTHDL;

	print "\t${listName}_ida_v1.txt created\n";
	return 1;
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

