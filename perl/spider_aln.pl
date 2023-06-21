#!/usr/bin/perl -w
# @date 31/01/2008
# @author HB
# Change:
# - Option for shift alignment only to replace ida_sh_aln.pl
# - Option for averaging with lower limit
# - Fix spider_avg function with no doc_init (Untested)
# - Fix problem with -exclude
# - transform inside script
#   filter ref inside script
# - TODO spider_omg version???
#   Fix problem of [doc].spi created
# - Shift align with initial document & no mask
# Identical to 1.6
# - now allow binning in program for faster processing

use POSIX;

$scriptName = "SPIDER_ALN_BIN.PL";
$version = '2.0';
$vdate = '2012/09/05';

print "\#$scriptName v$version $vdate\n";

if ($#ARGV < 4) {
	&print_usage;
	exit;
}

# default argument
$SPIDER_BIN = 'spider';
$ref = '';
$docOutputPrefix = 'doc_aln_';
$doAlign = 1;
@box = (80,120,80,120,80,120);
$searchRadius = 95;
$exclude = 5;
@bandpass = (.01,.05,3);
$searchType = 0;
$lowerLimit = 0;
$docInit = '';
$mask = '';
$deleteScript = 0;
$bin = 1;
# Parsing arguments
$i = 0;
for ($i = 0; $i < $#ARGV; $i++) {
	if ($ARGV[$i] eq '-name') {
		$name = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-ref') {
		$ref = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-doc_prefix') {
		$docOutputPrefix = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-range') {
        ($start, $end) = split(',', $ARGV[++$i]);
 	} elsif ($ARGV[$i] eq '-box') {
		@box = split(',', $ARGV[++$i]);
	} elsif ($ARGV[$i] eq '-search_radius') {
		$searchRadius = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-exclude') {
		$exclude = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-bandpass') {
		@bandpass = split(',', $ARGV[++$i]);
	} elsif ($ARGV[$i] eq '-align') {
		$doAlign = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-search_type') {
		$searchType = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-lower_limit') {
		$lowerLimit = $ARGV[++$i];
   	} elsif ($ARGV[$i] eq '-mask') {
        	$mask = $ARGV[++$i];
		$mask =~ s/.spi$//;
	} elsif ($ARGV[$i] eq '-doc_init') {
		$docInit = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-bin') {
		$bin = $ARGV[++$i];
	} elsif ($ARGV[$i] eq '-script') {
		$deleteScript = 0;
		if ($i == $#ARGV -1) {
			$i++;
		}			
	} else {
		print "Unknown flag\n";
		exit;
	}
}
$output = $ARGV[$#ARGV];

# Checking
if (!(defined $name && defined $start)) {
	print "Two few arguments\n";
	exit;
}

# Random Id
$pid = $$;

# Prepare argument
$ref =~ s/\.spi$//i;
$docInit =~ s/\.spi$//i;
$docOutputPrefix .= $output;

$soc_script = 'spider_aln_'.$pid;

if ($searchType == 1) {
	&print_spider_shift_aln($soc_script, $name, $start, $end, $output, $ref, $mask, \@bandpass, $docInit, $docOutputPrefix, \@box);
} else {
	if ($doAlign) {
		&print_spider_aln($soc_script, $name, $start, $end, $output, $ref, \@bandpass, $docOutputPrefix, \@box, $searchRadius, $exclude, $docInit, $bin);
	} else {
		&print_spider_avg($soc_script, $name, $start, $end, $output, $lowerLimit, $docInit);    
	}
}

$cmd = $SPIDER_BIN . " soc/spi \@$soc_script";	
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
   	print " -doc_init doc_init_oda1_001\t initial document for rotation and translation\n";
  	print " -script	don't delete script\n";
	print " -bin 2\t allow binning for faster operation\n";
	print "Example:\n    ./spider_aln.pl -ref oda1hm_low.spi -doc_prefix doc_aln_ -range 1,20 -name raw_\\*\\*\\* avg_001\n";
}

sub print_spider_aln {

	my ($soc_script, $name, $start, $end, $output, $ref, $bandpass, $docOutputPrefix, $box, $searchRadius, $exclude, $docInit, $bin) = @_;

	$ref =~ s/\.spi//g;

	open(OUTHDL, ">${soc_script}.soc") || die ("Error opening file $\!\n");
	select OUTHDL;

	$name =~ s/(\*+)/\{$1\[particle_id\]\}/g;

	$box->[0] = floor($box->[0]/$bin);
	$box->[1] = floor($box->[1]/$bin);
	$box->[2] = floor($box->[2]/$bin);
	$box->[3] = floor($box->[3]/$bin);
	$box->[4] = floor($box->[4]/$bin);
	$box->[5] = floor($box->[5]/$bin);

	$searchRadius = ceil($searchRadius/$bin);

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
[doc_output]$docOutputPrefix	; output document file

EOF

if ($ref ne '') {
	print "FR G\n[ref]$ref\n\n";
	$exclude = 0;
} else {
	print "FR G\n[ref]ref\n\n";	
}

if ($docInit ne '') {
    print "FR G\n[doc_init]$docInit\n\n";
}
	print <<EOF2;

 ; --------------- Parameters  --------------------------------------
[bin]=$bin ; binning factor
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
[search_radius]=$searchRadius
[phi]=0	; starting phi for OR
[theta]=0	; starting theta for OR
[psi]=0	; starting psi for OR
[low_freq]=$bandpass->[0];
[hi_freq]=$bandpass->[1];
[halfwidth]=$bandpass->[2];
[zero]=0;
[one]=1;

 ; -------------- Create document ----------------------------------

DE
[doc_output]

DOC CREATE
[doc_output]
1	; key number
;

; --------------- Create blank subavg ------------------------------

[particle_id]=$start

FI x81,x82,x83
[input]
12,2,1

x81=x81/[bin];
x82=x82/[bin];
x83=x83/[bin];

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
	if ($bin > 1) {
		print "   IP\n   [input]\n   _21\n   x81,x82,x83\n\n";  
	} else {
		print "   CP\n   [input]\n   _21\n\n";
	}

   	if ($docInit ne '') {
      		print "   UD [particle_id],x11,x12,x13,x14,x15,x16\n   [doc_init]\n\n";
		print "   x14=x14/[bin]\n";
		print "   x15=x15/[bin]\n";
		print "   x16=x16/[bin]\n\n";
      		print "   RT 3D\n   _21\n   _1\n   x11,x12,x13\n\n";
      		print "   AD\n   [ref]\n   _1\n   [ref]\n*\n\n";
   	} else {
   		print "   AD\n   [ref]\n   _21\n   [ref]\n   *\n\n";        
	}
	print "LB1\n\n";
	print "CP\n[ref]\n_31\n\n";

} else {
	if ($bin > 1) {
		print "IP\n[ref]\n_31\nx81,x82,x83\n\n";
	} else {
		print "CP\n[ref]\n_31\n\n";
	}
}


print <<EOF3;



 ; ------------ START:  FITTING INPUT TO SUBAVG_INT -----------------

 ; Filter ref
FQ NP ; low pass
_31
_66
3
[hi_freq]

DO LB2 [particle_id]=[start],[end]   

EOF3

if ($bin > 1) {
    print "   IP\n   [input]\n   _21\n   x81,x82,x83\n\n";
} else {
    print "   CP\n   [input]\n   _21\n\n";
}
if ($docInit ne '') {    
    print "   UD [particle_id],x11,x12,x13,x14,x15,x16\n   [doc_init]\n\n";
    print "   x14=x14/[bin]\n";
    print "   x15=x15/[bin]\n";
    print "   x16=x16/[bin]\n";
    print "   ; Rotate input\n";
    print "   RT 3D\n   _21\n   _2\n   x11,x12,x13\n\n";
} else {
    print "   CP\n   _21\n   _2\n\n";
}

print <<EOF4;  

   ; Filter input
   FQ NP ; low pass
   _2
   _4
   (3)
   [hi_freq]      

   ;FQ NP ; hi pass
   ;_2
   ;_3
   ;(4)
   ;[low_freq]   
   
   CC
   _66
   _4
   _10

   x31=0
   x32=0
   x33=0
   x34=0
   x35=0
   x36=0

   PK 3 x31,x32,x33,x34,x35,x36,x37
   _10
   +
   [number_of_peaks],[origin_overide]
   n
   y
   [lowX],[upX]
   [lowY],[upY]
   [lowZ],[upZ]
   
     
SH F
_4
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
   x14=0
   x15=0
   x16=0

   PK 3 x11,x12,x13,x14,x15,x16,x17
   _10
   +
   [number_of_peaks],[origin_overide]
   n
   y
   [lowX],[upX]
   [lowY],[upY]
   [lowZ],[upZ]
   

   SH F
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
   _2
   _16
   x31,x32,x33

   SH F
   _16
   _17
   x34,x35,x36

 
   ; Add to subaverage
   AD
   [subavg]
   _17
   [subavg]
   *
   
   x34=x34*[bin];
   x35=x35*[bin];
   x36=x36*[bin];

   ; Save aligment
   SD [particle_id],x31,x32,x33,x34,x35,x36,x24
   [doc_output]

   ; Debug
   VM
   echo "$output - particle \{***[particle_id]\} done"   

LB2	; end loop

; end saving
SD E
[doc_output]

IF ([bin].GT.[one]) THEN
 CP
 [subavg]
 [subavg]_bin

 x81=x81*[bin]
 x82=x82*[bin]
 x83=x83*[bin]

 IP
 [subavg]_bin
 [subavg]
 x81,x82,x83
ENDIF

 ; ------------ END:  FITTING INPUT TO SUBAVG_INI ------------------

EN D    ; end of procedure

 ; </body></pre></html>

EOF4

# End writing

	select STDOUT;
	close OUTHDL;

	return 1
}

# Updated with $doc_init
sub print_spider_shift_aln {
    my ($soc_script, $name, $start, $end, $output, $ref, $mask, $bandpass, $docInit, $docOutputPrefix, $box) = @_;
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

EOF

if ($mask ne '') {
	print "FR G\n[mask]$mask\n\n";
} else {
	print "FR G\n[mask]mask\n\n";
}

if ($docInit ne '') {
	print "FR G\n[doc_init]$docInit\n\n";
}

print <<EOF1;
 ; --------------- Output file  -------------------------------------

FR G
[doc_output]$docOutputPrefix    ; document file

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

 ; ---------------- Preparation -----------------------------------
 
DE
[doc_output]

DOC CREATE
[doc_output]
1
;

 ; Filter ref

FQ NP ; low pass
[ref]
_66
3
[hi_freq]

EOF1

	if ($mask eq '') {
		print "[particle_id]=[start]\n\n";
		print "FI x81,x82,x83\n[input]\n12,2,1\n\n";		
		print "BL\n[mask]\nx81,x82,x83\nN\n1\n\n";
 	}
	print " ; ----------------   Align input to reference --------------------\n\n";
 
	print "DO LB1 [particle_id]=[start],[end]\n\n";	
 
	if ($docInit ne '') {    
   	print "   UD [particle_id],x11,x12,x13,x14,x15,x16\n   [doc_init]\n\n";
    	print "   ; Rotate input\n";
    	print "   RT 3D\n   [input]\n   _2\n   x11,x12,x13\n\n";
	} else {
    	print "   CP\n   [input]\n   _2\n\n";
	}

print <<EOF2;

   ; Filter input
   FQ NP ; low pass
   _2
   _4
   (3)
   [hi_freq]

;   FQ NP ; hi pass
;   _3
;   _4
;   (4)
;   [low_freq]
; temporary solution

   CC
   _66
   _4
   _10

   x34=0
   x35=0
   x36=0

   PK 3 x31,x32,x33,x34,x35,x36,x37
   _10
   +
   [number_of_peaks],[origin_overide]
   n
   y
   [lowX],[upX]
   [lowY],[upY]
   [lowZ],[upZ]
   
   
   SH F
   _4
   _11
   x34,x35,x36
   
   ; calculate cross correlation
   CC C,x37
   _66
   _11
   [mask]
   
   ; Save aligment
   SD [particle_id],[zero],[zero],[zero],x34,x35,x36,x37
   [doc_output]
   
LB1 ; end loop
 
; end saving
SD E
[doc_output]

EN D    ; end of procedure

 ; </body></pre></html>

EOF2
# End writing

        select STDOUT;
        close OUTHDL;

        return 1

}

sub print_spider_avg {
	my ($soc_script, $name, $start, $end, $output, $lowerLimit, $docInit) = @_;

	open(OUTHDL, ">${soc_script}.soc") || die ("Error opening file $\!\n");
	select OUTHDL;

	if ($docInit ne '') {
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

	if ($docInit ne '') {
		print <<EOF2;

FR G
[doc_init]$docInit ; Input document

; --------------- Parameters  --------------------------------------

[lower_limit]=$lowerLimit ; lower limit

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
   [doc_init]

   IF (x17.GE.[lower_limit]) THEN
      RT 3D
      [input]
      _1
      x11,x12,x13
        
      AD
      _1
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
