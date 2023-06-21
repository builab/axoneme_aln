#!/usr/bin/perl -w
# Script used to correct star file i.e. absolute path, output name etc.
# Update file glob for tomo file
# Last modified 2009/09/21: take care of empty field

use Cwd;

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
	print "No matching file!!! Terminated\n";
	exit (0);
}

# Print out file to modify
$curDir = getcwd;
@recs = <*.rec.mrc>;
$defaultPath = '';
if ($#recs >= 0) {
	$defaultPath = $curDir . '/' . $recs[0];
}

$path = getInput("Absolute path of tomo rec.", $defaultPath);

# Correct star files
foreach $file (@list) {
	open(FILEHDL, "$file") || die "Cannot open $file. $!\n";
	$output = $file;
	$output =~ s/\.star$/\.pif/g;
	@content = <FILEHDL>;
	$lineId = 0;
	foreach  (@content) {
		$line = $_;
		if (/_micrograph\.file_name/i) {
			$line =~ s/(micrograph\.file_name\s+).*(\s+)$/$1$path$2/g;
			$content[$lineId] = $line;
		}
		if (/_micrograph_filament\.file_name/i) {
			$line =~ s/micrograph_filament/micrograph_particle/g;
			$line =~ s/(micrograph_particle\.file_name\s+).*(\s+)$/$1$output$2/g;
			$content[$lineId] = $line;
		}
		if (/_micrograph_particle\.file_name/i) {
			$line =~ s/(micrograph_particle\.file_name\s+).*(\s+)$/$1$output$2/g;
			$content[$lineId] = $line;
		}
		$lineId++;
	}
	close FILEHDL;

	$bak_cmd = 'mv ' . $file . ' ' . $file . '~';
	system($bak_cmd);

	open(FILEHDL, ">$file") || die "Cannot open $file. $!\n";
	foreach (@content) {
		print FILEHDL $_;
	}
	close FILEHDL;
	
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
