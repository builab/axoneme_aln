#!/usr/bin/perl
# All purposed mtb_auto_aln script
# HB 2008/01/28

$scriptName = "MTB_AUTO_ALN.PL";
$version = '1.2';
$vdate = '2009/05/04';

print "\#$scriptName v$version $vdate\n";

if ($#ARGV < 2) {
	&print_usage;
    exit;
}

use lib qw(/mol/ish/Data/programs/perl_script/modules /mol/ish/Data/programs/perl_script/lib);
use LibTransform qw(get_transform_list_from_doc combine_transform_list);
use Bstar;

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

# Parsing arguments
$i = 0;

for ($i = 0; $i < $#ARGV-1; $i++) {
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
	} else {
		print "Unknown flag\n";
		exit;
	}
}
$output = $ARGV[$i];

if (!(defined $star_file)) {
	&print_usage;
	exit;
}
$tmp_data = 'raw';

# Random Id
$pid = $$;

# MAKE temporary dir for .pif file
$tmp_dir = $output . '_' . $pid;


# Temporary star file
$tmp_star_file = $star_file;
$tmp_star_file =~ s/\.star$/_${pid}\.star/i;


# Generate doc name
$avg_file =~ /\d{3}/i;
$number = $&;

# Get pif_file & number of particle
open (STARHDL, "$star_file") || die ("Cannot open file $!\n");

$pif_file = 1;
$no_particles = 0;

while (<STARHDL>) {
        if (/[\w-_\d]+\.pif/i) {
                $pif_file = $&;
        } elsif (/^\s*\d+/i) {
                $no_particles++;
        }
}
close STARHDL;

$mk_tmp_dir = 'mkdir ' . $tmp_dir;
print "$mk_tmp_dir\n";

print "cd $tmp_dir\n";

if ($doc_init ne '') {
	$doc_init =~ s/\.spi$//i;		
	$ln_doc_init = 'ln -s ../' . $doc_init . '.spi';
	print "$ln_doc_init\n";
}

if ($ref ne '') {
	$ref =~ s/\.spi$//i;
	$ln_ref = 'ln -s ../' . $ref . '.spi';
	print "$ln_ref\n";
}


# PICK
$pick_cmd = "bpick -extract " . $extract_radius . ',' . $extract_radius . ',' . $extract_radius . " -background -normalize " . $tmp_star_file;
print "$pick_cmd\n";

# SPLIT
$split_cmd = "bsplit -first 1 " . $pif_file . " " . $tmp_data . ".spi";
print "$split_cmd\n";

if ($no_particles > $numParticleAvg) {
	$exclude = int(($no_particles - $numParticleAvg)/2);
} else {
	$exclude = 0;
}

# Delete Pif
$rm_pif = 'rm ' . $pif_file;
print "$rm_pif\n";

# TODO Fix this mess
@del_list = ($tmp_data . '_*spi', $tmp_star_file);

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

if ($ref ne '') {
    $args{"-ref"} = $ref . ".spi";
    push (@del_list, "$ref.spi");
} elsif ($doAlign) {
    push (@del_list, "ref.spi");
}

if ($doc_init ne '') {
    $args{"-doc_init"} = $doc_init . ".spi";
    push (@del_list, "$doc_init.spi");
}

$aln_cmd = "spider_aln_new.pl";
foreach (sort {$a <=> $b} keys %args) {
    $aln_cmd .= " $_ $args{$_}";
}
$aln_cmd .= " $output";

print "$aln_cmd\n";

# CLEAN UP
$clean_cmd = "rm @del_list";
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
&generateCorrectedStar($star_file, "${tmp_dir}/${tmp_star_file}", "${doc_init}.spi");

# Change to tmp dir
chdir $tmp_dir;
if ($doc_init ne '') { system($ln_doc_init) };

if ($ref ne '') { system($ln_ref) };

system($pick_cmd);
system($split_cmd);
system($rm_pif);
system($aln_cmd);
system($clean_cmd);
system($mv_cmd);
chdir "..";
system($rm_tmp_dir);

exit;

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
}

sub generateCorrectedStar {
	my ($starFile, $outputStarFile, $docFile) = @_;   
	# Read star file
	my $star = Bstar->new();
	$star->read_bstar($starFile);
	# Read doc file
	if ($docFile ne '') {
		my @transformList = get_transform_list_from_doc($docFile);
		$star->calc_new_origins(\@transformList);
	}
	# Write star file        
	$star->write_bstar($outputStarFile);

	return 1;
}
