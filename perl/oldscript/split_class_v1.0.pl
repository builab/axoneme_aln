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
$version = "1.1";
$vdata = "2010/11/17";

print "\#$scriptName $version $vdate\n";

if ($#ARGV < 3) {
	print "Usage: split_class.pl doc_file star_file number_of_class class_column\n";
	exit(0);
}

$doc_file = $ARGV[0];
$star_file = $ARGV[1];
$no_of_classes = $ARGV[2];
$class_col = $ARGV[3] - 1; 

if (!(-e $doc_file)) {
        print "$doc_file does not exist\n";
        exit(0);
}




@transform = read_spider_doc($doc_file);

for ($class = 1; $class <= $no_of_classes; $class++) {
	$no_of_items = 0;
	@doc_class = ();
	@item = ();	
	$doc_class_file = $doc_file;	
	$star_class_file = $star_file;
	$class_text = sprintf('%0.2d', $class);
	$doc_class_file =~ s/(\d\d\d\.spi)$/c${class_text}_\1/i;
	$star_class_file =~  s/(\d\.star)$/c${class_text}_\1/i;
	#print "$doc_class_file\n";
	for ($i = 0; $i <= $#transform; $i++) {
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
	print "Number of class $class: $no_of_items (@item)\n";
	if ($no_of_items > 0) {
		$star = Bstar->new();
		$star->read_bstar($star_file);		
		print "Writing $doc_class_file ...\n";
		write_spider_doc(\@doc_class, $doc_class_file);
		print "Writing $star_class_file ...\n";
		$star->write_selected_records(\@item, $star_class_file);
	}
}
