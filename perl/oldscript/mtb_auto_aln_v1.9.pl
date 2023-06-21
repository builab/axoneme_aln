#!/usr/bin/perl
# All purposed mtb_auto_aln script
# HB 2008/01/28
# 20091009 Option to use bpick instead of boxstartend
# Option to run intraAln for 2 iteration
# TODO Simplify argument parsing into one hash
# 1.7: Don't need to link doc & star anymore
# 1.9: use /tmp as temporary folder to speed up
use Cwd;
use Data::Dumper;

$scriptName = "MTB_AUTO_ALN.PL";
$version = '1.9';
$vdate = '2011/09/13';

print "\#$scriptName v$version $vdate\n";

if ($#ARGV < 2) {
	&print_usage;
    exit;
}

use LibTransform qw(get_transform_list_from_doc combine_transform_list);
use Bstar1_6;

# Associated script
$spider_aln_script = 'spider_aln.pl';

# default argument
$doCmd = 1; # For debugging
$ref = '';
$doc_init = '';
$doc_output_prefix = 'doc_aln_';
$box = '80,120,80,120,80,120';
$extract_radius = 100;
$search_radius = $extract_radius-5;
$exclude = 5;
$bandpass = '.01,.05,3';
$avg_num = 0;
$doAlign = 1;
$numParticleAvg = 5;
$lower_limit = 0;
$deleteScript = 1;
$pickMethod = 0;
$iter = 1;
$searchType = 0;
$processingDir = '/tmp'; # TO CHANGE OR PUT INTO COMMAND LINE OPTION
$startingDir = getcwd;


# Parsing arguments
$i = 0;

for ($i = 0; $i < $#ARGV; $i++) {
	if ($ARGV[$i] eq '-star') {
		$star_file = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-ref') {
		$ref = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-doc_init') {
		$doc_init = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-doc_output_prefix') {
        	$doc_output_prefix = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-extract') {
		$extract_radius = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-box') {
		$box = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-search_radius') {
		$search_radius = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-exclude') {
		$exclude = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-bandpass') {
		$bandpass = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-avg') {
		$avg_num = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-align') {
		$doAlign = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-numAvg') {
		$numParticleAvg = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-lower_limit') {
		$lower_limit = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-script') {
		$deleteScript = 0;
		if ($i = $#ARGV - 1) {
			$i++;
		}
	} elsif ($ARGV[$i] eq '-pick') {
		$pickMethod = $ARGV[++$i];	
	} elsif ($ARGV[$i] eq '-iter') {
		$iter = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-printCmd') {
		$doCmd = 0;
	} elsif ($ARGV[$i] eq '-search_type') {
		$searchType = $ARGV[++$i];
	} else {
		print "Unknown flag\n";
		exit;
	}
}

$output = $ARGV[$#ARGV];

if (!(defined $star_file)) {
	&print_usage;
	exit;
}
$tmp_data = 'raw';

# Random Id
$pid = $$;

# MAKE temporary dir for .pif file
$tmp_dir = $processingDir . '/' . $output . '_' . $pid;

# Generate doc name
$avg_file =~ /\d{3}/i;
$number = $&;

# Get pif_file & number of particle
my $star = Bstar->new();

if (-e $star_file) {
	$star->read_bstar($star_file);
} else {
	exit(1);
}

$no_particles = $star->get_number_of_particles();

$mk_tmp_dir = 'mkdir ' . $tmp_dir;
print "$mk_tmp_dir\n";

print "cd $tmp_dir\n";
	
if ($no_particles > $numParticleAvg) {
	$exclude = int(($no_particles - $numParticleAvg)/2);
} else {
	$exclude = 0;
}

%args = ();
$args{"-range"} = '1,' . $no_particles;
$args{"-align"} = $doAlign;
$args{"-name"} = $tmp_data . '_\*\*\*';

if ($doAlign) {
    $args{"-doc_prefix"} = $startingDir . '/' . $doc_output_prefix;
    $args{"-box"} = $box;
    $args{"-bandpass"} =  $bandpass;
    $args{"-search_radius"} = $search_radius;
    $args{"-exclude"} = $exclude;
} else {
    $args{"-lower_limit"} = $lower_limit;    
}

if ($deleteScript == 0) {
	$args{"-script"} = "";
}

if ($ref ne '') {
    $args{"-ref"} = $startingDir . '/' . $ref;
}

if ($doc_init ne '') {
    $args{"-doc_init"} = $startingDir . '/' . $doc_init;
}

if ($searchType == 1) {
	$args{"-search_type"} = 1;
}


# Remove tmp dir
$rmCmd = 'rm -R ' . $tmp_dir;
print "$rmCmd\n";

# Debug
	
# DO IT
#if ($doCmd) {
	system($mk_tmp_dir);
	chdir($tmp_dir);
#}

if ($pickMethod == 0) {
	&pickDataBsoft("$startingDir/$star_file", "$startingDir/$doc_init");
}	else {
	&pickDataImod("$startingDir/$star_file", "$startingDir/$doc_init");
}

if ($ref ne '') {
	system("ln -s $startingDir/$ref .");
}
&iterRefAln(\%args, $output, $iter);

if ($doCmd) {
	@mvList = ();
	if (-e "${output}.spi") {
		push(@mvList, "${output}.spi");
	}
	if ($deleteScript == 0) {
		@scriptFiles = <*.soc>;
		foreach (@scriptFiles) {
			push(@mvList, $_);
		}
	}
	@spiderLog = <result.soc.*>;
	if ($#spiderLog >= 0) {
		foreach (@spiderLog) {
			push(@mvList, $_);
		}
	}	
	$mvCmd = 'mv ';
	foreach (@mvList) {
		$mvCmd = $mvCmd . $_ . ' ';
	}
	$mvCmd = $mvCmd . ' ' . $startingDir;
	print "$mvCmd\n"; 
	if ($#mvList >= 0) {
		system($mvCmd);
	}
	chdir $startingDir;
	system($rmCmd);
}

# Sub
sub print_usage {
   print "MTB_AUTO_ALN Script for automatic picking & align\n. See also SPIDER_ALN\n";
   print "Usage: mtb_auto_aln_init.pl -flag option output\n";
	print "Flag:\n";
	print " -star\t starFile\n";
	print " -doc_init doc_init_oda1_001\t\n";
	print " -doc_output_prefix doc_aln_\t\n";
	print " -bandpass low,hi,halfwidth\n";
	print " -ref ref\n";
	print " -box 80,120,80,120,80,120\n";
	print " -exclude 5\t exclude in initial average from both end\n";
	print " -search_radius 95\t search radius\n";
	print " -extract 100\t extract radius\n";
	print " -align 1\t 1 is align, 0 is just average\n";
	print " -numAvg 5\t number of particles to average as reference\n";
	print " -search_type 1 1=transtional, 0=rotational	 & translational (default 0)\n";
	print " -lower_limit .25\t threshold for averaging\n";
	print " -script	don't delete Spider script\n";	
	print " -pick 0\t picking using Bsoft (0, default) or Imod (1)\n";
	print " -printCmd\t print command only but not doing anything\n";
}

sub pickDataImod {
	my ($star_file, $doc_file) = @_;
	#print $star_file;	
	my $star = Bstar->new();
	$star->read_bstar($star_file);
	&generateCorrectedPoint($star_file, $doc_file,'point.txt');
	my $imageFile = $star->get_header_item('_map.3D_reconstruction.file_name');
	$boxXY = $extract_radius * 2;
	$sliceLow = $extract_radius;
	$sliceHigh = $extract_radius-1;

	$modelCmd = "point2model -open point.txt point.mod";
	$pickCmd = "boxstartend -model point.mod  -series $tmp_data -image $imageFile -box $boxXY,$boxXY -slices $sliceLow,$sliceHigh";
	print "$modelCmd\n$pickCmd\n";
	if ($doCmd) {
		system($modelCmd);
		system($pickCmd);	
	}
	for (my $i = 1; $i <= $#{$star->{_particleData}} + 1; $i++) {
		my $format = "%0.2d";
		if ($#{$star->{_particleData}} > 9) {
			$format = "%0.2d";
		}
		my $linkCmd = "ln -s $tmp_data.". sprintf($format, $i) . " ${tmp_data}_" . sprintf("%0.3d", $i) . ".mrc";
		my $convertCmd = "bimg ${tmp_data}_" . sprintf("%0.3d", $i) . ".mrc ${tmp_data}_" . sprintf("%0.3d", $i) . ".spi";
		my $cleanCmd = "rm ${tmp_data}_" . sprintf("%0.3d", $i) . ".mrc $tmp_data.". sprintf($format, $i);
		print "$linkCmd\n";
		print "$convertCmd\n";
		print "$cleanCmd\n";
		if ($doCmd) {
			system($linkCmd);
			system($convertCmd);
			system($cleanCmd);
		}
	}
	$star->DESTROY();
	return 1;
}

sub pickDataBsoft {
	my ($star_file, $doc_file) = @_;
	#print "$star_file ! Ich bin hier\n";

	my $corr_star_file = $star_file;
	$corr_star_file =~ s/^\.\.\///i;
	$corr_star_file =~ s/.*\/(.*)\.star$/$1_corr\.star/i;
	
	#Corrected Star File
	&generateCorrectedStarFile($star_file, $doc_file, $corr_star_file);
	
	# PICK	
	my $pick_cmd = "bpick -extract " . $extract_radius . ',' . $extract_radius . ',' . $extract_radius . ' -background -normalize -extension spi -base ' . $tmp_data . '_ ' . $corr_star_file;
	print "$pick_cmd\n";	
		
	my $clean_cmd = "rm $corr_star_file\n";
	print "$clean_cmd\n";
	if ($doCmd) {
		system($pick_cmd);
		system($clean_cmd);
	}	
	return 1;
}

sub generateCorrectedPoint {
	my ($star_file, $doc_file, $outputPointFile) = @_;   
	# Read star file
	my $star = Bstar->new();
	$star->read_bstar($star_file);
	# Read doc file
	if ($doc_file ne '') {
		$star->read_transform_file($doc_file);
		my $newStar = $star->new_origins();
		$newStar->write_imod_point($outputPointFile);
		$newStar->DESTROY();
	} else {
		$star->write_imod_point($outputPointFile);
	}
	$star->DESTROY();
	return 1;
}

sub generateCorrectedStarFile {
	my ($star_file, $doc_file, $corr_star_file,) = @_;   
	# Read star file
	my $star = Bstar->new();
	$star->read_bstar($star_file);
	# Read doc file
	#print "DEBUG: $doc_file\n";
	if ($doc_file ne '') {
		$star->read_transform_file($doc_file);
		my $newStar = $star->new_origins();
		$newStar->write_bstar($corr_star_file);
		$newStar->DESTROY();
	} else {
		$star->write_bstar($corr_star_file);
	}
	# Write corrected star file        	
	$star->DESTROY();
	return 1;
}

# Iter with ref
sub iterRefAln {
	my ($args, $output, $iter) = @_;
	
	my $count = 1;
	do 
	{
		my $aln_cmd = $spider_aln_script;
		foreach (sort {$a <=> $b} keys %{$args}) {
   		$aln_cmd .= " $_ $args->{$_}";
		}
		$aln_cmd .= " $output";
		print "$aln_cmd\n";
		if ($doCmd) {
			system($aln_cmd);
		}

		# In the case of iteration
		$count++;
		$args->{"-ref"} = 'ref_' . sprintf("%0.3d", $count) . '.spi';
		$copy_cmd = 'mv ' . $output . '.spi ref_' . sprintf("%0.3d", $count) . '.spi';
		if ($count <= $iter) {
			print "$copy_cmd\n";
			if ($doCmd) {
				system($copy_cmd);
			}	
		}	
	}  while ($count <= $iter);
	return 1;
}
