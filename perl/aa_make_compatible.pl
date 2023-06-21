#!/usr/bin/perl -w
# Making the old system to be compatible with new system
# HB 20100209
if ($#ARGV < 0) {
	print "Usage: aa_make_compatible.pl listIda.txt";
	exit(0);
}

open (LSTHDL, ">tmp.txt") || die "Cannot open $!\n";

$listFile = $ARGV[0];

while (<>) {
	chomp;
	if (/^\s*$/i) { next;}
	if (/^\#/i) { print LSTHDL "$_\n"; next;}
	@lines = split(' ', $_);
	$newStar = $lines[1];
	#print "$newStar\n";
	$newStar =~ s/(\d)ida_v1/ida_v1_$1/i;
	printf LSTHDL ("%-20s %20s %3d\n", $lines[0], $newStar, $lines[2]);
	for ($i = 1; $i <= 4; $i++) {
		$old = $lines[1];
		$old =~ s/ida_v1$/ida_v${i}/i;
		$new = $lines[1];
		$new =~ s/(\d)ida_v1/ida_v${i}_$1/i;	 		
		$cmd = 'mv star/' . $old . '.star star/' . $new . '.star';
		print "$cmd\n";
		system($cmd);
	}
}

$cmd = 'mv tmp.txt ' . $listFile;
print "$cmd\n";
system($cmd);
close LSTHDL
