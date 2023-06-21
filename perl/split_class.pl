#!/usr/bin/perl
# @Script: split_class.pl
# @purpose: split class into different star file & doc file
# @date 20101005
# @usage: split_class.pl doc_file star_file number_of_class class_column
# @update 20110117

use LibTransform qw(get_transform_list_from_doc combine_transform_list);
use rwSpi qw(read_spider_doc write_spider_doc write_data_to_spider_doc);
use Data::Dumper;
use Bstar1_6;

$scriptName = "SPLIT_CLASS.PL";
$version = "1.2";
$vdata = "2011/02/13";

print "\#$scriptName $version $vdate\n";

if ($#ARGV < 3) {
	print "List usage: split_class.pl -list list_file doc_prefix star_prefix number_of_class class_column\n";
	print "Single pair usage: split_class.pl doc_file star_file number_of_class class_column\n";
	print "Example:\n";
	print "\tsplit_class.pl -list list_wt.txt doc/doc_class03_ star/ 2 8\n";
	print "\tsplit_class.pl doc/doc_class03_wt_01_001.spi star/wt_01_1.spi 2 8\n";
	exit(0);
}

$hasList = 0;

if ($ARGV[0] eq '-list') {
	$list_file = $ARGV[1];
	$doc_prefix = $ARGV[2];
	$star_prefix = $ARGV[3];
	$no_of_classes = $ARGV[4];
	$class_col = $ARGV[5] - 1;
	$hasList = 1;
} else {
	$doc_file = $ARGV[0];
	$star_file = $ARGV[1];
	$no_of_classes = $ARGV[2];
	$class_col = $ARGV[3] - 1;
}


if ($hasList ==  0) {
	if (!(-e $doc_file)) {
        	print "$doc_file does not exist\n";
        	exit(0);
	}
	&split_class_individual($doc_file, $star_file, $no_of_classes, $class_col);
	
} else {
	&split_class_list($list_file, $doc_prefix, $star_prefix, $no_of_classes, $class_col);	
}


# spliting classes
sub split_class_individual {
	my ($doc_file, $star_file, $no_of_classes, $class_col) = @_;
	#print "$doc_file $star_file $no_of_classes $class_col\n";
	my @transform = read_spider_doc($doc_file);
	for (my $class = 1; $class <= $no_of_classes; $class++) {
		my $no_of_items = 0;
		my @doc_class = ();
		my @item = ();	
		my $doc_class_file = $doc_file;	
		my $star_class_file = $star_file;
		my $class_text = sprintf('%0.2d', $class);
		$doc_class_file =~ s/(\d\d\d\.spi)$/c${class_text}_\1/i;
		$star_class_file =~  s/(\d\.star)$/c${class_text}_\1/i;
		#print "$doc_class_file\n";
		for (my $i = 0; $i <= $#transform; $i++) {
			#print $transform[$i]->[0], "\n";
			if ($transform[$i]->[$class_col] == $class) {
				#print "$class $i\n";
				my @extract = @{$transform[$i]}[0 .. 6];
				push(@doc_class, \@extract);			
				push(@item, $i);
			}
		}
		if ($#doc_class >= 0) {
			$no_of_items = $#doc_class + 1;
		} 
		print "Class $class: $no_of_items (@item)\n";
		if ($no_of_items > 0) {
			$star = Bstar->new();
			$star->read_bstar($star_file);		
			print "Writing $doc_class_file ...\n";
			write_spider_doc(\@doc_class, $doc_class_file);
			print "Writing $star_class_file ...\n";
			$star->write_selected_records(\@item, $star_class_file);
		}
	}
	return 1;
}

sub split_class_list {
	my ($list_file, $doc_prefix, $star_prefix, $no_of_classes, $class_col) = @_;
	open (LSTHDL, "$list_file") || die ("Cannot open $list_file. $!\n");
	my @list = <LSTHDL>;
	close LSTHDL;
	foreach (@list) {
		if (/#/i) { next; };
                chomp;
		print "$_\n";
                my @line = split(' ', $_);
		my $doc_file = $doc_prefix . $line[0] . '.spi';
		my $star_file = $star_prefix . $line[1] . '.star';
		print "$doc_file $star_file $no_of_classes $class_col\n";
		&split_class_individual($doc_file, $star_file, $no_of_classes, $class_col);
	}

	for (my $class = 1; $class <= $no_of_classes; $class++) {
                my $class_text = sprintf('%0.2d', $class);
		$out_list_file = $list_file;
		$out_list_file =~ s/\.txt/_c${class_text}\.txt/i;
		
		print "-> Writing $out_list_file ...\n";
		open (OUTLSTHDL, ">$out_list_file") || die "Cannot write $out_list_file. $!\n";
		foreach (@list) {
			if (/^\s*#/i) { next; };
 			chomp;
                	my @line = split(' ', $_);
			my $doc_class_file = $line[0];
                	my $star_class_file = $line[1];
                	$doc_class_file =~ s/(\d\d\d)$/c${class_text}_\1/i;
                	$star_class_file =~  s/(\d)$/c${class_text}_\1/i;
			
			my @transform = read_spider_doc($doc_prefix . $line[0] . '.spi');
			my $classExist = 0;	
			for (my $i = 0; $i <= $#transform; $i++) {
				if ($transform[$i]->[$class_col] == $class) {
					$classExist = 1;
					last;
				}
			}
			
			if ($classExist == 1) {
				my $line = sprintf("%-20s %17s %4d\n", $doc_class_file, $star_class_file, $line[2]);
				print OUTLSTHDL "$line";
			}
		}
		close OUTLSTHDL;
	}
	return 1
}
