#!/usr/bin/perl
# All purposed mtb_auto_aln script
# @author HB 20080128
# v1.1
# @date: 20090505
# Update
# 20090922 option not delete script
use lib qw(/mol/ish/Data/programs/perl_script/modules /mol/ish/Data/programs/perl_script/lib);
use LibTransform qw(get_transform_list_from_doc combine_transform_list);
use Bstar1_6;

# Associated script
$spider_aln_script = 'spider_aln_v1.4.pl';

if ($#ARGV < 2) {
	&print_usage;
    exit;
}


# default argument
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
$tfm_tmp_data = 'out';

# Get number of particle
my $star = Bstar->new();

if (-e $star_file) {
	$star->read_bstar($star_file);
} else {
	exit(1);
}
$no_particles = $star->get_number_of_particles();

# Generate doc name
$avg_file =~ /\d{3}/i;
$number = $&;

# Random Id
$pid = $$;

# MAKE temporary dir for .pif file
$tmp_dir = $output . '_' . $pid;

$mk_tmp_dir = 'mkdir ' . $tmp_dir;
print "$mk_tmp_dir\n";
print "cd $tmp_dir\n";

# PICK
$pick_cmd = "bpick -extract " . $extract_radius . ' -background -normalize -extension spi -base ' . $tmp_data . '_ ../' . $star_file;
print "$pick_cmd\n";

# TRANSFORM
if ($doc_init ne '') {
	$tfm_cmd = 'tfm_series.pl -nu ' . $tmp_data . '_ 1 ' . $no_particles . ' ' . $tfm_tmp_data . '_ ../' . $doc_init ;
	print "$tfm_cmd\n";
	$rm_raw = 'rm ' . $tmp_data . '*.spi';
	print "$rm_raw\n";
}


#ALN
$data = $tmp_data;

if ($doc_init ne '') {
	$data = $tfm_tmp_data;
}

if ($no_particles > $numParticleAvg) {
	$exclude = int(($no_particles - $numParticleAvg)/2);
} else {
	$exclude = 0;
}

if ($deleteScript) {
	$scriptArg = '';
} else {
	$scriptArg = ' -script';
}

if ($ref ne '') {
	$aln_cmd = $spider_aln_script . ' -ref ../' . $ref . ' -range 1,' . $no_particles . ' -doc_prefix ../' . $doc_output_prefix . ' -box ' . $box . ' -bandpass ' . $bandpass . $scriptArg . ' -exclude 0 -search_radius ' . $search_radius . ' -name ' . $data . '_\*\*\* ' . $output;	
} else {
	if ($doAlign) {
		$aln_cmd = $spider_aln_script . ' -range 1,' . $no_particles . ' -doc_prefix ../' . $doc_output_prefix . ' -box ' . $box . ' -bandpass ' . $bandpass . $scriptArg . ' -exclude ' . $exclude . ' -search_radius ' . $search_radius . ' -name ' . $data . '_\*\*\* ' . $output;
	} else {
		$aln_cmd = $spider_aln_script . ' -range 1,' . $no_particles . ' -align ' . $doAlign . $scriptArg . ' -lower_limit ' . $lower_limit . ' -doc_init ../' . $doc_init . ' -name ' . $data . '_\*\*\* ' . $output;
	}
	$ref = 'ref';
}
print "$aln_cmd\n";

# CLEAN UP
$clean_cmd = 'rm ' . $tfm_tmp_data . '_*.spi';
print "$clean_cmd\n";

# MOVE UP
$mv_cmd = 'mv *.* ../';
print "$mv_cmd\n";

print "cd ..\n";

# Remove tmp dir
$rm_tmp_dir = 'rm -R ' . $tmp_dir;
print "$rm_tmp_dir\n";

# DEBUG
#exit;

# DO IT
system($mk_tmp_dir);

# Change to tmp dir
chdir $tmp_dir;

system($pick_cmd);

if ($doc_init ne '') { system($tfm_cmd); system($rm_raw); };

system($aln_cmd);
system($clean_cmd);
system($mv_cmd);

chdir "..";
system($rm_tmp_dir);


sub print_usage {
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
	print " -script	don't delete script\n";
}
