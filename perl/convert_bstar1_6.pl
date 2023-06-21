#!/usr/bin/perl
# Script to convert bstar from version 1.6 to 1.3
# convert_bstar.pl star_file(s)

use Bstar1_6;

if ($#ARGV < 0) {
	print "Usage: convert_bstar1_6.pl star_file(s)\n";
	exit;
}

foreach $file (@ARGV) {
	$star = Bstar->new();
	$star->read_bstar($file);
	$star->convert_to_bstar1_6();
	system("cp $file ${file}.bak");
	$star->write_bstar($file);
}

print "That's it.\n";
