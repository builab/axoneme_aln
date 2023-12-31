#!/usr/bin/perl
# Calling spider AD command
# Usage: spider_avg.pl -output outputFile inputFile(s)
# HB 20080121
# v1.1

$scriptName = "SPIDER_AVG.PL";
$version = '1.1';
$vdate = '2008/01/21';
print "\#$scriptName v$version $vdate\n";

if ($#ARGV < 3) {
	&print_usage;
	exit (1);
}

$listFile = '';
$output = '';
$list = [];

for ($i = 0; $i <= $#ARGV; $i++) {
	if ($ARGV[$i] eq '-output') {
		$output = $ARGV[++$i];
		$output =~ s/.spi$//;
	} elsif ($ARGV[$i] eq '-list') {
		$listFile = $ARGV[++$i];
	} else {
		$item = $ARGV[$i];
		$item =~ s/.spi$//;
		push(@{$list}, $item);
	}	
}

$j = $#{$list};

if ($listFile ne '') {
	open (FILEHDL, $listFile) || die ("Cannot open $listFile. $!\n");
	while (<FILEHDL>) {
		if (/\#/i) {
			next;
		}
		if (/^\s$/i) {
			next;
		}
		@line = split(' ', $_);
		$line[0] =~ s/.spi$//;
		$list->[++$j] = $line[0];
	}
	close FILEHDL;
}

if (($output == '') && ($#{$list} < 0)) {
	&print_usage();
	exit;
} else {
	print "Output: $output\n";
}

# Random Id
@chars = ("a" .. "z", 0 .. 9);
$rand_id = join("", @chars[map {rand @chars} (1 .. 4)]);
$soc_script = 'spider_avg_' . $rand_id;

print "Input list:\n";
foreach (@{$list}) {
	print "\t$_\n";
}

&print_spider_avg($list, $output);

$cmd = 'spider soc/spi @' . $soc_script;
print "Running: $cmd\n";
system($cmd);

$rm_cmd = 'rm ' . $soc_script . '.soc';
system($rm_cmd);

exit;

##############
sub print_usage {
	print "Usage: spider_avg.pl -output outputFile inputFile(s)\n";
	print "Flags:\n";
	print "\t-output\t outputFile (required)\n";
	print "\t-list\t listFile\n";
	print "Example: spider_avg.pl -output output -list a.txt a b d\n";
}

sub print_spider_avg {
        my ($list, $output) = @_;

        open(OUTHDL, ">${soc_script}.soc") || die ("Error opening file $\!\n");
        select OUTHDL;
	
		
	# Start print soc file
        print <<TAG;

 ; <html><head><title>Alignment dynein/MTs</title></head><body><pre>
 ;
 ; PURPOSE: Taking straight average of several particles
 ; SOURCE: avg.soc (Generated by $scriptName)
 ; 

TAG

print "AD\n";
for  (my $i == 0; $i <= $#{$list}; $i++) {
	print "$list->[$i]\n";
	if ($i == 1) {
		print "$output\n";
	}	
}

print "*\n\n";

print <<TAG;

EN D    ; end of procedure

 ; </body></pre></html>

TAG
# End print soc file

        select STDOUT;
        close OUTHDL;
        return 1;
}

