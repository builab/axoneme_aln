#!/usr/bin/perl
# @script mtb_class_avg.pl
# @purpose Getting the class average from supervised classification
# @author HB
# @date 20080520
# @lastmod 20100607

if ($#ARGV < 2) {
	&print_usage;
    exit;
}


# default argument
$ref = '';
$doc_init = '';
$extract_radius = 100;
$no_of_classes = 0;
$lower_limit = 0;

# Parsing arguments
$i = 0;

for ($i = 0; $i < $#ARGV-1; $i++) {
	if ($ARGV[$i] eq '-star') {
		$star_file = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-doc_init') {
		$doc_init = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-extract') {
		$extract_radius = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-lower_limit') {
		$lower_limit = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-classNum') {
		$no_of_classes = $ARGV[++$i];
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

# Get pif_file & number of particle
open (STARHDL, "$star_file") || die ("Cannot open file $!\n");

$pif_file = 1;
$no_particle = 0;

while (<STARHDL>) {
        if (/[\w-_\d]+\.pif/i) {
                $pif_file = $&;
        } elsif (/^\s*\d+/i) {
                $no_particle++;
        }
}
close STARHDL;

# Generate doc name
$avg_file =~ /\d{3}/i;
$number = $&;

# Random Id
@chars = ("a" .. "z", 0 .. 9);
$rand_id = join("", @chars[map {rand @chars} (1 .. 4)]);

# MAKE temporary dir for .pif file
$tmp_dir = $output . '_' . $rand_id;

$mk_tmp_dir = 'mkdir ' . $tmp_dir;
print "$mk_tmp_dir\n";

print "cd $tmp_dir\n";

# Make soft link to star file
$ln_star = 'ln -s ../' . $star_file;
print "$ln_star\n";

$ln_doc_init = 'ln -s ../' . $doc_init . '.spi';
print "$ln_doc_init\n";

# PICK
$pick_cmd = "bpick -extract " . $extract_radius . " -background -normalize " . $star_file;
print "$pick_cmd\n";

# SPLIT
$split_cmd = "bsplit -first 1 " . $pif_file . " " . $tmp_data . ".spi";
print "$split_cmd\n";


$soc_script = 'avg_' . $rand_id;
$name = $tmp_data . '_***';
$start = 1;

$avg_cmd = 'spider_linux_mp_opt64 soc/spi @' . $soc_script;
print "$avg_cmd\n";



# CLEAN UP
$clean_cmd = "rm " . $pif_file . ' ' . $tmp_data . '_*spi ' . $star_file . ' *.soc ' . $doc_init . '.spi';
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

system($ln_star);
system($ln_doc_init);
system($pick_cmd);
system($split_cmd);

if ($no_of_classes > 0) {
	&print_class_avg($soc_script, $name, $start, $no_particle, $output, $doc_init, $lower_limit, $no_of_classes);
} else {
	&print_avg($soc_script, $name, $start, $no_particle, $output, $doc_init, $lower_limit);
}

system($avg_cmd);
exit;
system($clean_cmd);
system($mv_cmd);

chdir "..";
system($rm_tmp_dir);


sub print_usage {
    print "Usage: mtb_class_avg.pl -flag option output\n";
	print "Flag:\n";
	print " -star\t starFile\n";
	print " -doc_init doc_init_oda1_001\t\n";
	print " -extract 100\t extract radius\n";
	print " -lower_limit .25\t threshold for averaging\n";
	print " -classNum 2\t class to get average\n";
}

sub print_avg {
}

sub print_class_avg {
	my ($soc_script, $name, $start, $end, $output, $doc_init, $lower_limit, $no_of_classes) = @_;

	open(OUTHDL, ">${soc_script}.soc") || die ("Error opening file $\!\n");
	select OUTHDL;


	$name =~ s/(\*+)/\{$1\[particle_id\]\}/g;
	
	# Printing spider_aln.soc content
	print <<EOF;

 ; <html><head><title>Alignment dynein/MTs</title></head><body><pre>
 ;
 ; PURPOSE: Split into odd & even data for FSC
 ; SOURCE: mtb_class_avg.pl
 ;
 ; \@date 20080420
 ; \@author HB
 
 ; ------------ Input files -----------------------------------------

FR G
[input]${name} ; Input data

 ; --------------- Output file  -------------------------------------

FR G
[class_avg]${output}_c{***[class_id]}	; odd output

FR G
[doc]$doc_init ; Input document

[lower_limit]=$lower_limit ; lower limit
[particle_id]=1
[number_of_classes]=$no_of_classes;
[start]=$start;
[end]=$end;
[zero]=0;

; --------------- Create blank subavg ------------------------------

FI x81,x82,x83
[input]
12,2,1

DO LB2 [class_id]= 0,[number_of_classes]

   BL
   [class_avg]
   x81,x82,x83
   N
   0

LB2

 ; --------------- Averaging    -------------------------------------

DO LB1 [particle_id]=[start],[end]
	   	
   UD S [particle_id],x11,x12,x13,x14,x15,x16,x17,[class_id],x19
   [doc]

   IF (x17.GE.[lower_limit]) THEN
      RT 3D
      [input]
      _1
      x11,x12,x13

      SH 3
      _1
      _2
      x14,x15,x16
      
      AD
      _2
      [class_avg]
      [class_avg]
      *

      ; Debug	
      VM
      echo "$output - add particle \{***[particle_id]\} to class \{***[class_id]\}"  
   ENDIF	
LB1

 ; --------------- Done -------------------------------------------- 

EN D    ; end of procedure
 ; </body></pre></html>

EOF
# End writing

        select STDOUT; 
        close OUTHDL; 
        return 1;


}
