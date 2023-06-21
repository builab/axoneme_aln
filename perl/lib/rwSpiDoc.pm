#!/usr/bin/perl
# Class rwSpiDoc
# Read Write & Combine Spider Doc
# @author HB
# @date 23122007
package rwSpiDoc;

use strict;

#use Data::Dumper;

#Constructor
sub new {
	my ($class) = @_;
	my $self = {
		_output => undef
		_transform => undef
		};
		bless $self, $class;
		return $self;
}

# Clear data
sub clear  {
	my ($self) = shift;
	$self->{_output} = undef;
	$self->{_transform_list} = undef;
	return $self;
}

sub set_output {
	my ($self, $output) = @_;
	$self->{_output} = $output;
	return $self;
}

# Read spider document
sub read_spi_doc  {
	my ($self, $tfm_file) = @_;
	
	%transform = ();

	open(TFMHDL, $tfm_file) || die ("Cannot open file $tfm_file. $! \n");
	while (<TFMHDL>) {
		chomp;
		if (/;/i) { next; }		
		my ($phi, $theta, $psi, $dx, $dy, $dz, $ccc) = split(' ', $_);
		
	}
	
	close TFMHDL;

return $self;
}

# Write spider document
sub write_spider_doc {
	return $self;
}
