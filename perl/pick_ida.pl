#!/usr/bin/perl -w
# Pick Ida variant best correlated to model
# Usage: ./pick_ida.pl list_ida.txt
# HB 2008/08/07

$scriptName = 'PICK_IDA.PL';
$version = '1.0';
$vdate = '2008/08/12';

print "#$scriptName v$version $vdate\n";
$docDir = 'doc';
$starDir = 'star';

if ($#ARGV < 1) {
	print "pick_ida_var.pl list_ida.txt doMove\n";
	exit;
}

$doMove = $ARGV[1];

open(FILEHDL, "$ARGV[0]") || die "Cannot open file. $!\n";

while (<FILEHDL>) {
	chomp;
	if (/\#/) { next;}
	if (/^\s*$/) { next;}
	@line = split(' ', $_);
	$avgFile = shift(@line);
	$starFile = shift(@line);
	$suffix = $avgFile;
	$suffix =~ s/ida_v1/ida_all/g;
	$inputDoc = 'doc_shift_' . $suffix . '.spi';	
	open (INHDL, "${docDir}/${inputDoc}") || die "Cannot open ${docDir}/${inputDoc}. $!\n";
	$max_cc = 0;
	@header = ();
	while (<INHDL>) {
		chomp;
		if (/;/i) {
			push(@header, $_);
			next;
		}
		@line = split(' ', $_);
		$cc = pop(@line);
		if ($cc > $max_cc) {
			$max_cc = $cc;
			$max_var = shift @line;
			@shift = @line[4..6];
		}
	}
	close INHDL;
	#print "$max_var $max_cc\n";

	&shiftDoc("${docDir}/${inputDoc}", $max_var);

	$outputFile = 'doc_shift_' . $avgFile . '.spi';
	open (OUTHDL, ">$docDir/$outputFile") || die "Cannot open $docDir/$outputFile. $!\n";
	foreach (@header) {
		print OUTHDL "$_\n";
	}
	print "\# Pick Var $max_var with $max_cc. Write $outputFile ...\n"; 
	printf OUTHDL ("%3d %2d %12.4f %12.4f %12.4f  %12.4f %12.4f %12.4f %12.5f\n", 1, 7, 0, 0, 0, $shift[0], $shift[1], $shift[2], $max_cc);
	close OUTHDL;

	if ($max_var != 1) {
		shiftIda(["${docDir}/doc_init_${avgFile}.spi", "${docDir}/doc_intra_${avgFile}.spi", "${avgFile}.spi", "${starDir}/${starFile}.star"], $max_var);

	}

		
}

close FILEHDL;


sub shiftIda {
	my ($refList, $toVar) = @_;

	my @list = @{$refList};

	foreach (@list) {	
		for (my $old_var = 1; $old_var <=4; $old_var++) {
			my $old_file = $_;
			$old_file =~ s/ida_v\d/ida_v${old_var}/i;
			$cmd1 = 'mv ' . $old_file . ' tmp' . $old_var;
			print "$cmd1\n";
			if ($doMove) { system($cmd1);}
		}
		for (my $old_var = 1; $old_var <=4; $old_var++) {
			$new_var = ($old_var + $toVar - 1) % 4;
			if ($new_var == 0) {
				$new_var = 4;
			}
			$new_file = $_;
			$new_file =~ s/ida_v\d/ida_v${old_var}/i;
	
			$cmd2 = 'mv tmp' . $new_var . ' ' . $new_file;
			print "$cmd2\n";
			if ($doMove) { system($cmd2);}
		}
	}
	return 1; 
}

sub shiftDoc {
	my ($docFile, $toVar) = @_;
	
	open(INHDL, "$docFile") || die "Cannot open $docFile\n";

	my @content = ();
	my @header = ();
	while (<INHDL>) {
		chomp;
		if (/;/i) {
			push(@header, $_);
			next;
		}
		push(@content, $_);
	}
	close INHDL;

	@new_order = 1 .. 4;
	
	if ($toVar == 1) {
		return 1;
	} else {
		@new_order[0 .. 4-$toVar] = $toVar .. 4;
		@new_order[5-$toVar .. 3] = 1 .. $toVar-1;
	}

	print "\# @new_order\n";

	open(OUTHDL, ">$docFile") || die "Cannot create $docFile\n";
	foreach (@header) {
		print OUTHDL "$_\n";
	}
	my $count = 1;
	foreach my $record (@new_order) {
		$line = $content[$record - 1];
		$line =~ s/^(\s+)\d+/$1$count/g;
		print OUTHDL "$line\n";
		$count++;
	}
	close OUTHDL;
	return 1
}
