package rwSpi;

# Function list
# 	read_spi_doc(filename) OK
#	write_spi_doc(input, outputfile) OK
# @author HB
# @date 19/03/2007
# @last_mod: 13/08/2007 to handle all docs
#				 05/10/2010 to new function for compatibility

use strict;
use warnings;

use vars qw(@ISA @EXPORT);
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(read_spider_doc write_spider_doc write_data_to_spider_doc);

# Read spi doc and return a hash with key as in the doc
sub read_spider_doc {
	my ($input) = @_;

	if ($#_ == -1) {
		return -1;
	}

	open(FILEHDL, $input) || die ("Error reading file $input\n");
	my @input_data = <FILEHDL>;
	close FILEHDL;

	my @output = ();

	foreach my $line (@input_data) {
        chomp $line; 
		if ($line =~ /^\s+\d+\s+/i) {
			my @data = split(' ', $line);
         my $key = shift(@data); # get key
         shift(@data); # get rid of number of key
			push(@output, \@data);
		}
	}

	return @output;
}

sub write_spider_doc {
	my ($input, $outputfile) = @_;
	
	if ($#_ < 1) {
		return -1;
	}

	open(DOCHDL, ">$outputfile") || die ("Error creating file");
	select DOCHDL;

	&print_time_stamp($outputfile);

	for (my $key = 0; $key <= $#{$input}; $key++) {
		my $data = $input->[$key-1];
		printf("%5d %2d", $key + 1, $#{$data}+1);
		for (my $i = 0; $i <= $#{$data}; $i++) {
			 printf("     %8.5G",$data->[$i]);
		}
		print "\n";
	}
	
	select STDOUT;
	close DOCHDL;
	
	return 1;
}

sub write_data_to_spider_doc {
	my ($data, $outputFile) = @_;

	open(DOCHDL, ">$outputFile") || die ("Error creating file");
	select DOCHDL;

	&print_time_stamp($outputFile);

	my $key = 1;
	foreach my $record (@{$data}) {
		printf("%5d %2d", $key++, $#{$record}+1);
		for (my $i = 0; $i <= $#{$record}; $i++) {
			printf("% 12.5G",$record->[$i]);
		}
		print "\n";
	}

	close DOCHDL;
	select STDOUT;
	return 1;
}

sub print_time_stamp {
	my $input = shift;
	my %month = (0 => "JAN", 1 => "FEB", 2 => "MAR", 3 => "APR",
					 4 => "MAY", 5 => "JUN", 6 => "JUL", 7 => "AUG",
					 8 => "SEP", 9 => "OCT", 10 => "NOV", 11 => "DEC");
	my $currtime = time();
	my @timelist = localtime($currtime);
	
	my $year = $timelist[5] + 1900;

    # print header file
	print " ;soc/spi   $timelist[3]-$month{$timelist[4]}-$year";
	print " AT $timelist[2]:$timelist[1]:$timelist[0]   $input\n";
	return 1;
}


1;
