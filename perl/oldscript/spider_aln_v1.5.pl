#!/usr/bin/perl -w
# @date 31/01/2008
# @author HB
# @version: 1.25 (20090922)
# Change:
# - Option for shift alignment only to replace ida_sh_aln.pl
# - Option for averaging with lower limit
# - Fix spider_avg function with no doc_init (Untested)
# - Fix problem with -exclude
# - Using high ref
# - option not delete script


if ($#ARGV < 4) {
	&print_usage;
	exit;
}

# default argument
$ref = '';
$doc = 'doc_aln_';
$doAlign = 1;
@box = (80,120,80,120,80,120);
$search_radius = 95;
$exclude = 5;
@bandpass = (.01,.05,3);
$searchType = 0;
$lower_limit = 0;
$doc_init = '';
$deleteScript = 1;
# Parsing arguments
$i = 0;
for ($i = 0; $i < $#ARGV-1; $i++) {
	if ($ARGV[$i] eq '-name') {
		$name = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-ref') {
		$ref = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-doc_prefix') {
		$doc = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-range') {
        	($start, $end) = split(',', $ARGV[++$i]);
 	} elsif ($ARGV[$i] eq '-box') {
		@box = split(',', $ARGV[++$i]);
	} elsif ($ARGV[$i] eq '-search_radius') {
		$search_radius = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-exclude') {
		$exclude = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-bandpass') {
		@bandpass = split(',', $ARGV[++$i]);
	} elsif ($ARGV[$i] eq '-align') {
		$doAlign = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-search_type') {
		$searchType = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-lower_limit') {
		$lower_limit = $ARGV[++$i];
    	} elsif ($ARGV[$i] eq '-mask') {
        	$mask = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-doc_init') {
		$doc_init = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-script') {
		$deleteScript = 0;	
	} else {
		print "Unknown flag\n";
		exit;
	}
}
$output = $ARGV[$i];

# Checking
if (!(defined $name && defined $start)) {
	print "Two few arguments\n";
	exit;
}

# Random Id
@chars = ("a" .. "z", 0 .. 9);
$rand_id = join("", @chars[map {rand @chars} (1 .. 4)]);

$soc_script = 'spider_aln_'.$rand_id;

if ($searchType == 1) {
	&print_spider_shift_aln($soc_script, $name, $start, $end, $output, $ref, $mask, \@bandpass, $doc, \@box);
} else {
	if ($doAlign) {
		&print_spider_aln($soc_script, $name, $start, $end, $output, $ref, \@bandpass, $doc, \@box, $search_radius, $exclude);
	} else {
		&print_spider_avg($soc_script, $name, $start, $end, $output, $doc_init, $lower_limit);
	}
}

$cmd = "spider_linux_mpfftw_opt64 soc/spi \@$soc_script";	
print "$cmd\n\n";
system($cmd);
if ($deleteScript) {
	system("rm ${soc_script}.soc");
}
exit;

#################
sub print_usage {
	print "Usage:\n";
	print "    ./spider_aln.pl -flag option output\n";
	print "Flag:\n";
	print " -ref oda1\t\t reference file (without using average as reference)\n";
	print " -name oda1_\\*\\*\\*\t input pattern\n";
	print " -range 1,25\t\t range from start to end\n";
	print " -doc_prefix doc_aln_\t output document prefix\n";
	print " -box 80,120,80,120,80,120\t lower & upper range for x,y,z for CC peak picking\n";
	print " -search_radius 95\t rotational search radius\n";
	print " -exclude 5\t\t exclude particles at both end to avoid curve microtuble\n";
	print " -bandpass .05,.2,3\t low, high freq & sigma\n";	
	print " -align 1\t 1 align, 2 average without align (default 1)\n";
	print " -search_type 1\t 1 = translational, 0 = rotational & translational\n";
   print " -mask mask_file\t mask file for translational (1) search type\n";
	print " -lower_limit .25\t lower limit of cross correlation coefficient for averaging\n";
	print " -script	don't delete script\n";
	print "Example:\n    ./spider_aln.pl -ref oda1hm_low -doc_prefix doc_aln_ -range 1,20 -name raw_\\*\\*\\* avg_001\n";
}

sub print_spider_aln {

	my ($soc_script, $name, $start, $end, $output, $ref, $bandpass, $doc, $box, $search_radius, $exclude) = @_;

	$ref =~ s/\.spi//g;

	open(OUTHDL, ">${soc_script}.soc") || die ("Error opening file $\!\n");
	select OUTHDL;

	$name =~ s/(\*+)/\{$1\[particle_id\]\}/g;

	# Printing spider_aln.soc content
	print <<EOF;

 ; <html><head><title>Alignment dynein/MTs</title></head><body><pre>
 ;
 ; PURPOSE: Fit models using filtered file and produce subaverage
 ; SOURCE: spider_aln.soc (based on subavg.soc, spider_aln.pl)
 ;
 ; \@date 20080204
 ; \@author HB
 ; TODO self produce filtered file
 
 ; ------------ Input files -----------------------------------------

FR G
[input]${name} ; Input data

 ; --------------- Output file  -------------------------------------

FR G
[subavg]${output}	; high resolution output

FR G
[doc]${doc}${output}	; document file

EOF

if ($ref ne '') {
	print "FR G\n[ref]$ref\n\n";
	$exclude = 0;
} else {
	print "FR G\n[ref]ref\n\n";	
}

	print <<EOF2;

 ; --------------- Parameters  --------------------------------------

[start]=$start ; start number
[end]=$end ; end number
[avg_start]=[start] + $exclude ; start number to average
[avg_end] = [end] - $exclude ; end number to average
[number_of_peaks]=1
[origin_overide]=0
[lowX]=$box->[0]	; lower limit for peak search
[upX]=$box->[1]	; upper limit for peak search
[lowY]=$box->[2]
[upY]=$box->[3]
[lowZ]=$box->[4]
[upZ]=$box->[5]
[search_radius]=$search_radius
[phi]=0	; starting phi for OR
[theta]=0	; starting theta for OR
[psi]=0	; starting psi for OR
[low_freq]=$bandpass->[0];
[hi_freq]=$bandpass->[1];
[halfwidth]=$bandpass->[2];
[zero]=0;

 ; -------------- Create document ----------------------------------

DOC CREATE
[doc]
1	; key number
;

; --------------- Create blank subavg ------------------------------

[particle_id]=$start

FI x81,x82,x83
[input]
12,2,1

BL
[subavg]
x81,x82,x83
N
0

EOF2

if ($ref eq '') {
	print " ; --------------- Create initial average ---------------------------\n\n";
	print "BL\n[ref]\nx81,x82,x83\nN\n0\n\n";
	print "DO LB1 [particle_id]=[avg_start],[avg_end]\n\n";
	#print "FQ NP\n[input]\n_1\n(3)\n[hi_freq]\n\n";
	#print "CP\n_1\n_2\n\n";
	#print ";FQ NP\n_1\n_2\n(4)\n[low_freq]\n\n";
	print "AD\n[ref]\n[input]\n[ref]\n\n";
	print "LB1\n\n";
}

print <<EOF3;

; Filter ref
FQ NP
[ref]
_66
3
[hi_freq]

 ; ------------ START:  FITTING INPUT TO SUBAVG_INT -----------------


DO LB2 [particle_id]=[start],[end]
   ; Filter input
   FQ NP ; low pass
   [input]
   _1
   (3)
   [hi_freq]

  ; FQ NP ; hi pass
  ; _1
  ; _2
  ; (4)
  ; [low_freq]

  ; temporary solution	
   CP
   _1
   _2

   CC
   _66
   _2
   _10

   x31=0
   x32=0
   x33=0

   PK 3 x31,x32,x33,x34,x35,x36
   _10
   +
   [number_of_peaks],[origin_overide]
   n
   y
   [lowX],[upX]
   [lowY],[upY]
   [lowZ],[upZ]
     
   SH 3
   _2
   _11
   x34,x35,x36

   OR 3Q x21,x22,x23
   _66
   _11
   [search_radius]
   [phi],[theta]
   [psi]

   RT 3D
   _11
   _12
   x21,x22,x23

   ; Fitting round 2
   CC
   _66
   _12
   _10

   x11=0
   x12=0
   x13=0

   PK 3 x11,x12,x13,x14,x15,x16
   _10
   +
   [number_of_peaks],[origin_overide]
   n
   y
   [lowX],[upX]
   [lowY],[upY]
   [lowZ],[upZ]

   SH 3
   _12
   _13
   x14,x15,x16

   ; Sum alignment
   SA 3,x41,x42,x43,x44,x45,x46
   [zero],[zero],[zero]
   x34,x35,x36
   x21,x22,x23
   x14,x15,x16

   OR 3Q x21,x22,x23,x24
   _66
   _13
   [search_radius]
   [phi],[theta]
   [psi]
	
   SA 3,x31,x32,x33,x34,x35,x36
   x41,x42,x43
   x44,x45,x46
   x21,x22,x23
   [zero],[zero],[zero]

   ; transform original file
   RT 3D
   [input]
   _16
   x31,x32,x33

   SH 3
   _16
   _17
   x34,x35,x36

 
   ; Add to subaverage
   AD
   [subavg]
   _17
   [subavg]
   *

   ; Save aligment
   SD [particle_id],x31,x32,x33,x34,x35,x36,x24
   [doc]

   ; Debug
   VM
   echo "$output - particle \{***[particle_id]\} done"   

LB2	; end loop

; end saving
SD E
[doc]

 ; ------------ END:  FITTING INPUT TO SUBAVG_INI ------------------

EN D    ; end of procedure

 ; </body></pre></html>

EOF3
# End writing

	select STDOUT;
	close OUTHDL;

	return 1
}

sub print_spider_shift_aln {
    my ($soc_script, $name, $start, $end, $output, $ref, $mask, $bandpass, $doc, $box) = @_;
    open(OUTHDL, ">${soc_script}.soc") || die ("Error opening file $\!\n");
    select OUTHDL;
   
    $name =~ s/(\*+)/\{$1\[particle_id\]\}/g;
    
    # Printing spider_aln.soc content
    print <<EOF;

 ; <html><head><title>Alignment dynein/MTs</title></head><body><pre>
 ;
 ; PURPOSE: Align 4 variant of Ida to a model
 ; SOURCE: spider_aln.soc (based on subavg.soc, spider_aln.pl)
 ;
 ; \@date 20080228
 ; \@author HB
 
 ; ------------ Input files -----------------------------------------

FR G
[input]${name} ; Input data

FR G
[ref]${ref} ; Reference

FR G
[mask]${mask} ; Mask for CCC calculation

 ; --------------- Output file  -------------------------------------

FR G
[doc]${doc}${output}    ; document file

 ; --------------- Parameters  --------------------------------------

[start]=$start ; start number
[end]=$end ; end number
[number_of_peaks]=1
[origin_overide]=0
[lowX]=$box->[0]    ; lower limit for peak search
[upX]=$box->[1] ; upper limit for peak search
[lowY]=$box->[2]
[upY]=$box->[3]
[lowZ]=$box->[4]
[upZ]=$box->[5]
[low_freq]=$bandpass->[0];
[hi_freq]=$bandpass->[1];
[halfwidth]=$bandpass->[2];
[zero]=0

 ; ---------------- Create document -------------------------------
 
 DOC CREATE
 [doc]
 1
 ;
 

 ; ----------------   Align input to reference --------------------

 ; filter ref
FQ NP
[ref]
_66
3
[hi_freq]

DO LB1 [particle_id]=[start],[end]
   ; Filter input
   FQ NP ; low pass
   [input]
   _1
   (3)
   [hi_freq]

;   FQ NP ; hi pass
;   _1
;   _2
;   (4)
;   [low_freq]
; temporary solution
   CP
   _1
   _2	

   CC
   _66
   _2
   _10

   x34=0
   x35=0
   x36=0

   PK 3 x31,x32,x33,x34,x35,x36
   _10
   +
   [number_of_peaks],[origin_overide]
   n
   y
   [lowX],[upX]
   [lowY],[upY]
   [lowZ],[upZ]
   
   SH 3
   _2
   _11
   x34,x35,x36
   
   ; calculate cross correlation
   CC C,x37
   _66
   _11
   [mask]
   
   ; Save aligment
   SD [particle_id],[zero],[zero],[zero],x34,x35,x36,x37
   [doc]
   
LB1 ; end loop
 
; end saving
SD E
[doc]

EN D    ; end of procedure

 ; </body></pre></html>

EOF
# End writing

        select STDOUT;
        close OUTHDL;

        return 1

}

sub print_spider_avg {
	my ($soc_script, $name, $start, $end, $output, $doc_init, $lower_limit) = @_;

	open(OUTHDL, ">${soc_script}.soc") || die ("Error opening file $\!\n");
	select OUTHDL;

	if ($doc_init ne '') {
		$name =~ s/(\*+)/\{$1\[particle_id\]\}/g;
	}
	
	# Printing spider_aln.soc content
	print <<EOF;

 ; <html><head><title>Alignment dynein/MTs</title></head><body><pre>
 ;
 ; PURPOSE: Fit models using filtered file and produce subaverage
 ; SOURCE: spider_aln.soc (based on subavg.soc, spider_aln.pl)
 ;
 ; \@date 20080204
 ; \@author HB
 ; TODO self produce filtered file
 
 ; ------------ Input files -----------------------------------------

FR G
[input]${name} ; Input data

 ; --------------- Output file  -------------------------------------

FR G
[subavg]${output}	; high resolution output


EOF

	if ($doc_init ne '') {
		print <<EOF2;

FR G
[doc]$doc_init ; Input document

[lower_limit]=$lower_limit ; lower limit

; --------------- Create blank subavg ------------------------------

[particle_id]=$start

FI x81,x82,x83
[input]
12,2,1

BL
[subavg]
x81,x82,x83
N
0

 ; --------------- Averaging    -------------------------------------

DO LB1 [particle_id]=$start,$end
	   	
   UD S [particle_id],x11,x12,x13,x14,x15,x16,x17
   [doc]

   IF (x17.GE.[lower_limit]) THEN
      AD
      [input]
      [subavg]
      [subavg]
      *

      ; Debug	
      VM
      echo "$output - \{%F7.4%x17\} Add particle \{***[particle_id]\} "   

   ENDIF
LB1

EOF2

	} else {
		print <<EOF3;

 ; --------------- Averaging    -------------------------------------

AD S
[input]
$start,$end
[subavg]

EOF3

}

	print <<EOF4;

 ; --------------- Done -------------------------------------------- 

EN D    ; end of procedure
 ; </body></pre></html>

EOF4
# End writing

        select STDOUT; 
        close OUTHDL; 
        return 1;

}
