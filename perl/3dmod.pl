#!/usr/bin/perl -w
# @purpose View spider files by 3dmod directly
# @author Huy Bui
# @date 20080826

if ($#ARGV < 0) {
	print "Two few arguments\n";
	exit(0);
}

$length = 4;
$nsam_offset = 12;
$labbyt_offset = 22;
$do_swap = 0;
$SWAPTRIG = 655356;
$BOF = 0;

$inputFile = $ARGV[$#ARGV];

@newArgs = @ARGV[0 .. $#ARGV-1];

if ($inputFile =~ /^(.*)\.spi$/i) {
	open(FILEHDL, $inputFile) || die "Cannot open $inputFile. $!";
	binmode FILEHDL; 
	read (FILEHDL, $buffer, $length);
	$nslice = unpack 'f', $buffer;
	# Checking for byte swapping
	if ((abs($nslice) > $SWAPTRIG) || (abs($nslice) < 1)) {
    	$do_swap = 1;
	}
	if ($do_swap) {
		$nslice = unpack 'f', reverse $buffer;
		read (FILEHDL, $buffer, $length);
		$nrow = unpack 'f', reverse $buffer;
		seek(FILEHDL, ($nsam_offset-1)*$length, $BOF);
		read (FILEHDL, $buffer, $length);
		$nsam = unpack 'f', reverse $buffer;
		seek(FILEHDL, ($labbyt_offset-1)*$length, $BOF);
		read (FILEHDL, $buffer, $length);
		$labbyt = unpack 'f', reverse $buffer;
	} else {
		read (FILEHDL, $buffer, $length);
		$nrow = unpack 'f', $buffer;
		seek(FILEHDL, ($nsam_offset-1)*$length, $BOF);
		read (FILEHDL, $buffer, $length);
		$nsam = unpack 'f', $buffer;
		seek(FILEHDL, ($labbyt_offset-1)*$length, $BOF);
		read (FILEHDL, $buffer, $length);
		$labbyt = unpack 'f', $buffer;
	}
	close FILEHDL;

	push (@newArgs, "-r $nsam,$nrow,$nslice");
	push (@newArgs, "-t 2");
	push (@newArgs, "-H $labbyt");

	if ($do_swap) {
		push(@newArgs, "-w");
	}
} 

$displayCmd = '3dmod ';
foreach (@newArgs) {
	$displayCmd .= " $_";
}

$displayCmd .= " $ARGV[$#ARGV]";
print "$displayCmd\n";

# Display
system($displayCmd);

exit;
