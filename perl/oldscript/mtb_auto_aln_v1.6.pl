#!/usr/bin/perl
# All purposed mtb_auto_aln script
# HB 2008/01/28
# 20091009 Option to use bpick instead of boxstartend
# Option to run intraAln for 2 iteration
# TODO Simplify argument parsing into one hash

use Data::Dumper;

$scriptName = "MTB_AUTO_ALN.PL";
$version = '1.6';
$vdate = '2009/12/01';

print "\#$scriptName v$version $vdate\n";

if ($#ARGV < 2) {
	&print_usage;
    exit;
}

use lib qw(/mol/ish/Data/programs/perl_script/modules /mol/ish/Data/programs/perl_script/lib);
use LibTransform qw(get_transform_list_from_doc combine_transform_list);
use Bstar;

# Associated script
$spider_aln_script = 'spider_aln_v1.6.pl';

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
	} elsif ($ARGV[$i] eq '-pick') {
		$pickMethod = $ARGV[++$i];	
	} elsif ($ARGV[$i] eq '-iter') {
		$iter = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-printCmd') {
		$doCmd = 0;
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
$tmp_dir = $output . '_' . $pid;

# Generate doc name
$avg_file =~ /\d{3}/i;
$number = $&;

# Get pif_file & number of particle
# TODO change Bstar for neater header.
my $star = Bstar->new();

if (-e $star_file) {
	$star->read_bstar($star_file);
} else {
	exit(1);
}

$no_particles = $#{$star->{_particleData}} + 1;

foreach (@{$star->{_header}}) {	
	#print "$_\n";		
	if (/_micrograph_particle\.file_name/i) {			
		my @lines = split(' ', $_);
		$pif_file = $lines[1];
		last;
	}	
}

#open (STARHDL, "$star_file") || die ("Cannot open file $!\n");
#$pif_file = 1;
#$no_particles = 0;

#while (<STARHDL>) {
#        if (/[\w-_\d]+\.pif/i) {
#                $pif_file = $&;
#        } elsif (/^\s*\d+/i) {
#                $no_particles++;
#        }
#}
#close STARHDL;

$mk_tmp_dir = 'mkdir ' . $tmp_dir;
print "$mk_tmp_dir\n";

print "cd $tmp_dir\n";

if ($doc_init ne '') {
	$doc_init =~ s/\.spi$//i;
	$doc_init .= '.spi';		
	$ln_doc_init = 'ln -s ../' . $doc_init;
	print "$ln_doc_init\n";
}

if ($ref ne '') {
	$ref =~ s/\.spi$//i;
	$ref .= '.spi';
	$ln_ref = 'ln -s ../' . $ref;
	print "$ln_ref\n";
}

if ($no_particles > $numParticleAvg) {
	$exclude = int(($no_particles - $numParticleAvg)/2);
} else {
	$exclude = 0;
}


# TODO Fix this mess
@del_list = ("$tmp_data*.spi");

if ($iter >= 2) {
	for ($i = 2; $i <= $iter; $i++) {
		push(@del_list, "ref_" . sprintf("%0.3d", $i) . ".spi");
	}
}

%args = ();
$args{"-range"} = '1,' . $no_particles;
$args{"-align"} = $doAlign;
$args{"-name"} = $tmp_data . '_\*\*\*';

if ($doAlign) {
    $args{"-doc_prefix"} = $doc_output_prefix;
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
    $args{"-ref"} = $ref;
    push (@del_list, $ref);
} elsif ($doAlign) {
    push (@del_list, "ref.spi");
}

if ($doc_init ne '') {
    $args{"-doc_init"} = $doc_init;
    push (@del_list, $doc_init);
}


# CLEAN UP
$clean_cmd = "rm @del_list";
print "$clean_cmd\n";

# MOVE UP
if ($doAlign != 0) {
	$mv_cmd = 'mv ' . $output . '.spi ' . $doc_output_prefix . $output . '.spi' . ' ../';
}	else {
	$mv_cmd = 'mv ' . $output . '.spi ../';
}

print "$mv_cmd\n";

print "cd ..\n";

# Remove tmp dir
$rm_tmp_dir = 'rm -R ' . $tmp_dir;
print "$rm_tmp_dir\n";

# Debug
	
# DO IT
if ($doCmd) {
	system($mk_tmp_dir);
	chdir($tmp_dir);
}

if ($pickMethod == 0) {
	&pickDataBsoft("../$star_file", "../$doc_init");
}	else {
	&pickDataImod("../$star_file", "../$doc_init");
}

# Change to tmp dir
if ($doCmd) {
	if ($doc_init ne '') { system($ln_doc_init) };
	if ($ref ne '') { system($ln_ref) };
}

&iterRefAln(\%args, $output, $iter);

if ($doCmd) {	
	system($clean_cmd);
	system($mv_cmd);
	chdir "..";
	system($rm_tmp_dir);
}

# Sub
sub print_usage {
   print "MTB_AUTO_ALN Script for automatic picking & align\n. See also SPIDER_ALN";
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
	$star->read_transform_file($doc_file);
	$star = $star->new_origins();
	
	$star->write_imod_point('point.txt');
	#print Dumper($star->{_header});
	foreach (@{$star->{_header}}) {	
		#print "$_\n";		
		if (/_micrograph\.file_name/i) {			
			my @lines = split(' ', $_);
			$imageFile = $lines[1];
			last;
		}	
	}

	$boxXY = $extract_radius * 2;
	$sliceLow = $extract_radius;
	$sliceHigh = $extract_radius-1;

	$modelCmd = "point2model -open -zero point.txt point.mod";
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
	$corr_star_file =~ s/\.star$/_corr\.star/i;
	
	#print "$corr_star_file\n";
	
	
	#Corrected Star File
	&generateCorrectedStarFile($star_file, $doc_file, $corr_star_file);
	
	# PICK	
	my $pick_cmd = "bpick -extract " . $extract_radius . ',' . $extract_radius . ',' . $extract_radius . " -background -normalize " . $corr_star_file;
	print "$pick_cmd\n";	
	

	
	# SPLIT
	my $split_cmd = "bsplit -first 1 " . $pif_file . " " . $tmp_data . ".spi";
	print "$split_cmd\n";
	
	my $clean_cmd = "rm $pif_file $corr_star_file\n";
	print "$clean_cmd\n";
	if ($doCmd) {
		system($pick_cmd);
		system($split_cmd);
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
		$star = $star->new_origins();
	}
	# Write star file        
	$star->write_imod_point($outputPointFile);
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
