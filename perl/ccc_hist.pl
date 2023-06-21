#!/usr/bin/perl -w
# Script to get the cumulative distribution of ccc from document files
# Usage: ./ccc_hist.pl document_file
# @author HB
# @date 20080407
# TODO ccc_hist.pl column_number input_files
# See also: txthist.pl


if ($#ARGV == -1) {
        print "Usage: ccc_hist.pl input_file(s)\n";
        exit;
}

$scriptName = "CCC_HIST.PL";
$version = "1.0";
$vdate = "20080407";

print "\#$scriptName $version $vdate";

$lowest = .1; # Lowest boundary
$highest = .3; # Highest boundary
$bin = 22; # number of bins
$range = ($highest - $lowest)/($bin-2); # range of each bin
$max_step = 40; # number of step

# Initilization
%hist = ();

for ($i = 0; $i < $bin; $i++) {
        $hist{$i} = 0;
}

# List dir with the pattern & read

while (<>) { # Parsing
    chomp;
    if (/;/i) {
         next;
    }
    
	@line = split(' ', $_);
	$ccc = pop(@line);
	#print "$ccc\n";

	if ($ccc < $lowest) {
		$h = 0;
	} elsif ($ccc >= $highest) {
		$h = $bin - 1;
	} else {
	    $h = int(($ccc - $lowest)/$range) + 1;
	}

        $hist{$h}++;
}

# Cumulative
for ($i = 1; $i < $bin; $i++) {
        $hist{$i} = $hist{$i} + $hist{$i-1};
}

# Print out histogram
@val = sort {$b <=> $a} (values %hist);
$max_val = shift(@val);
$step = 1;

if ($max_val/$step > $max_step) {
        $step = round($max_val/$max_step);
}

# INFORMATION
print "CCC_HIST (07/04/2008)\n";
printf "Range: %3.2f\n", $range;
printf "\n\n";

# Print scale
$tick_no = 5;
while ($tick_no > .5*$max_val/$step) {
        $tick_no = round($tick_no/2);
}

print "\n";
printf '%9s  ', 'Range';
for ($i = 0; $i<= $tick_no ; $i++) {
        printf '%-*d', round($max_val/($step*$tick_no)), $i*round($max_val/$tick_no);
}
print "\n";



print "----------------------------------------------------------------------------\n";


for ($i = 0; $i < $bin; $i++) {
	if ($i == 0) {
		$start = 0;
	} elsif ($i == $bin -1) {
		$start = $highest;
	} else {
		$start = $lowest + $i*$range;
	}
    printf ("%9.2f |", $start);
    for ($j = 1; $j <= round($hist{$i}/$step); $j++) {
          print "x";
    }
        print " $hist{$i}\n";
}

print "\n";

# sub round
sub round {
    my($number) = shift;
    return int($number + .5);
}

