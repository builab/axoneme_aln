#!/usr/bin/perl -w
# Pick Ida variant best correlated to model
# Usage: ./axon_reorder.pl flagName doublet1no isOdaPrj
# HB 2009/10/18

use Data::Dumper;

$scriptName = 'AXON_REORDER.PL';
$version = '1.0';
$vdate = '2009/10/18';

print "#$scriptName v$version $vdate\n";
$docDir = 'doc';
$starDir = 'star';

$isOdaPrj = 0;

if ($#ARGV < 2) {
	print "axon_reorder.pl flagName doublet1No isOdaPrj\n";
	print "\tflagName mbo1_11\n";
	print "\tdoublet1No Doublet number which is identified as doublet 1\n";
	print "\tisOdaPrj 1 or 0 (default 0), reorder both ODA & IDA or ODA document only\n";
	exit;
}

$flagName = $ARGV[0];
$doubletOne = $ARGV[1];
$isOdaPrj = $ARGV[2];

@doc24List = ("doc_init_", "doc_intra_", "doc_rough_", "doc_refined_", "doc_cbn_", "doc_inter_", "doc_total_");
@doc96List = ("doc_init_", "doc_intra_", "doc_shift_", "doc_cbn_", "doc_inter_", "doc_total_");

@fileList = &makeFileList($flagName, $isOdaPrj);
&reorderAxon(\@fileList, $doubletOne);

sub makeFileList {
	my ($flagName, $isOdaPrj) = @_;
	my @fileList = ();
	# doc file
	foreach $docPrefix (@doc24List) {
			my $docFile = $docDir . '/' . $docPrefix . $flagName . '_001.spi';
			#print $docFile, "\n";
			push(@fileList, $docFile);
	}
	# star file
	my $starFile = $starDir . '/' . $flagName . '_1.star';
	#print $starFile, "\n";
	push(@fileList, $starFile);

	
	if ($isOdaPrj == 0) {
		foreach $docPrefix (@doc96List) {
			if ($docPrefix =~ /doc_shift_/) {
					my $docFile = $docDir . '/' . $docPrefix . $flagName . '_ida_all_001.spi';
					#print $docFile, "\n";
					push(@fileList, $docFile);
			}				
			for (my $idaVar = 1; $idaVar <=4; $idaVar++) {
				#doc file
				my $docFile = $docDir . '/' . $docPrefix . $flagName . '_ida_v' . $idaVar . '_001.spi';
				#print $docFile, "\n";
				push(@fileList, $docFile);						
			}
		}
		# Star file
		for (my $idaVar = 1; $idaVar <=4; $idaVar++) {
				my $starFile = $starDir . '/' . $flagName . '_ida_v' . $idaVar . '_1.star';
				#print $starFile, "\n";
				push(@fileList, $starFile);
		}
	}
	return @fileList;
}

sub reorderAxon {
	my ($fileList, $doubletOne) = @_;

	my @fileList = @{$fileList};

#	print Dumper(@fileList);
	
	my @new_order = 1 .. 9;
	my @old_order = 1 .. 9;
	if ($doubletOne == 1) {
		return 1;
	} else {
		@new_order[$doubletOne-1 .. 8] = @old_order[0 .. 9-$doubletOne];
		@new_order[0 .. $doubletOne-2] = @old_order[10-$doubletOne .. 8];
	}
	
	print "#New doublet order: @new_order\n";		
	foreach my $file (@fileList) {
		#print "$file\n";
		foreach my $doubletId (@old_order) {
			my $inputFile = $file;
			$inputFile =~ s/1(\.[(spi)(star)])/$doubletId$1/i;
			my $tmpFile = 'tmp_' . $doubletId;
			$cmd = 'mv ' . $inputFile . ' '. $tmpFile;
			if (-e $inputFile) {
				print "$cmd\n";
				system($cmd);
			}	
		}	
		foreach my $doubletId (@old_order) {
			my $outputFile = $file;
			$outputFile =~	s/\d(\.[(spi)(star)])/$new_order[$doubletId-1]$1/i;
			my $tmpFile = 'tmp_' . $doubletId;
			$cmd = 'mv ' . $tmpFile . ' ' . $outputFile;
			if (-e $tmpFile) {
				print "$cmd\n";
				system($cmd);
			}
		}
	}	
	return 1;
}
