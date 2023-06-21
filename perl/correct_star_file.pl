#!/usr/bin/perl 
# Script used to correct star file i.e. absolute path, output name etc.
# Update file glob for tomo file
# Last modified 2009/09/21: take care of empty field
# Last modified 2010/06/14 using Bstar1_6 & convert to 1.6 version of bstar

use Cwd;
use Bstar1_6;

$dir = '.';
opendir(DIRHDL, $dir) || die "Cannot open $dir. $!\n";

print "Pattern (e.g. wt14_): ";
$pattern = <>;
chomp $pattern;

print "Found files:\n";
@list = ();
foreach $name (sort readdir(DIRHDL)) {
    if ($name =~ /^$pattern.*\.star$/i) {
      print "\t$name\n";
		push(@list, $name);
    }
}
closedir DIRHDL;

if ($#list < 0) {
	print "No matching files!!! Terminated\n";
	exit (0);
}

# Print out file to modify
$curDir = getcwd;
@recs = <*_rec.mrc>;
$defaultPath = '';
if ($#recs >= 0) {
	$defaultPath = $curDir . '/' . $recs[0];
}

$path = getInput("Absolute path of tomo rec.", $defaultPath);

# Correct star files
foreach $file (@list) {
	$star = Bstar->new();
	$star->read_bstar($file);
	$star->set_header_item('_map.3D_reconstruction.file_name', $path);
	system("cp $file ${file}.bak");
	$star->write_bstar($file);
}

print "\nMission complete\n";


sub getInput {
	my ($question, $defaultAnswer) = @_;
	print "$question [$defaultAnswer]: ";
	chomp (my $input = <>);
	if ($input =~ /^\S+$/i) {
		return $input;
	}
	return $defaultAnswer;
}
