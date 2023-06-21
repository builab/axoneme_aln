#!/usr/bin/perl
# Class Bstar to read & write very simple star file
# @author HB
# @date 20081108
# Update header

# Reading Star file into an array
package Bstar;

use strict;
use LibTransform qw(get_transform_list_from_doc combine_transform_list round reverse_transform);
use Data::Dumper;


#Constructor
sub new {
	my ($class) = @_;
	my $self = {
		_name => undef,
		_header => undef,
		_particleFields => undef,
		_particleData => undef,
		_particleBad => undef,
		_transformList => undef,
		_version => undef
		};
		bless $self, $class;
		return $self;
}

# Read bstar new version 1.6 & 1.3
sub read_bstar {
	my ($self, $starFile) = @_;
	if (!(-e $starFile)) {
		print "$starFile not available\n";
		return -1;
	}

	open(FILEHDL, $starFile) || die ("Cannot open file $starFile. $! \n");
	my @content = <FILEHDL>;
	close FILEHDL;

	my $isheader = 1;	
 	my @headerBlock = ();
	my @particleFields = ();
	my @dataBlock = ();
	my @badBlock = ();
	my $isData = 0;
	my $isBadData = 0;

	for (my $i = 0; $i <= $#content; $i++) {	
		if ($content[$i] =~ /\#/i) { next; }	
		if ($content[$i] =~ /^\s+$/i) { next; }
		if ($content[$i] =~ /^data_/i) {                        
			$self->{_name} = $content[$i]; 
			$self->{_name} =~ s/^data_\s*//i; #print "$self->{_name}\n";
			next;
      } 

		# Reading header block
     	if (($isheader == 1) && ($content[$i] =~ /^_/i)) {
     		if ($content[$i] =~ /^_map\./) { 
     			$self->{_version} = '1.6';
     		} else {
     			$self->{_version} = '1.3';
     		}
			while ($isheader == 1) {			
				if ($content[$i] =~ /^[^_]/i) { $isheader = 0; last; }						
				chomp $content[$i]; #print $content[$i], "\n";	     		
				push(@headerBlock, $content[$i++]);					
			}			
		}

		$self->parseHeader(\@headerBlock);
		
		# Reading data block		
		if ($content[$i] =~ /^loop_/i) {
			if ($content[$i+1] =~/_particle.id/) {
				$isData = 1;
		      $i++;			
	   	   while ($isData == 1) {
	      		if (($i > $#content) || ($content[$i] =~ /^\s+$/)) { $isData = 0 ; last; };
					chomp $content[$i]; #print $content[$i], "\n";				
	         	push(@dataBlock, $content[$i++]);	
				}		
			} elsif ($content[$i+1] =~/_particle.bad/) {
				$isBadData = 1;
				$i++;
				while ($isBadData == 1) {
	      		if (($i > $#content) || ($content[$i] =~ /^\s+$/)) { $isBadData = 0 ; last; };
					chomp $content[$i]; #print $content[$i], "\n";				
	         	push(@badBlock, $content[$i++]);	
				}
			}				
		}
		$self->parseParticleData(\@dataBlock); #print Dumper(@dataBlock);
		$self->parseParticleBad(\@badBlock);
	}
	
	if ($self->get_version() eq '1.3') {
		$self->convert_to_bstar1_6();
	}
	
   return $self;
}

sub info {
	my ($self, $fieldName) = @_;
	if (defined $fieldName) {		
		print Dumper($self->{$fieldName});
	} else {
		print Dumper($self);	
	}
}

sub parseHeader {
	my ($self, $headerBlock) = @_; #print Dumper($headerBlock);
	my @header = ();
	#print Dumper($headerBlock);
	for (my $i = 0; $i <= $#{$headerBlock}; $i++) { 
		my @line = split(' ', $headerBlock->[$i]);
		#push (@header, 1);
		push(@header, [@line[0 .. 1]]);
	}	
	$self->{_header} = \@header;
	return $self;
}

sub parseParticleBad {
	my ($self, $badBlock) = @_;
	my @particleBad = ();
	if ($#{$badBlock} < 0) { return;}
	for (my $i = 0; $i <= $#{$badBlock}; $i++) {
		while ($badBlock->[$i] =~ /^\s*\d+/) { # coordinate part
			my @line = split(' ', $badBlock->[$i++]);
			push(@particleBad, [@line[0 .. $#line]]);
		}
	}
	$self->{_particleBad} = \@particleBad;
	return $self;
}
sub parseParticleData {
	my ($self, $dataBlock) = @_; #print Dumper($dataBlock);
	my @particleFields = ();
	my @particleData = ();
	if ($#{$dataBlock} < 0) { return;}
	#print Dumper($dataBlock);
 	#print "Last item ", $dataBlock->[$#{$dataBlock}], "\n";
	for (my $i = 0; $i <= $#{$dataBlock}; $i++) {
		while ($dataBlock->[$i] =~ /^_particle/i) {
	  		push(@particleFields, $dataBlock->[$i++]);						  		
		}		
	   while ($dataBlock->[$i] =~ /^\s*\d+/) { # coordinate part
			my @line = split(' ', $dataBlock->[$i++]);
			push(@particleData, [@line[0 .. $#line]]);
		}
	}
	$self->{_particleFields} = \@particleFields;
	$self->{_particleData} = \@particleData;	
	return $self;
}

sub convert_to_bstar1_6 {
	my ($self) = shift;
	if ($self->get_version() eq '1.3') {		
		splice @{$self->{_particleFields}}, 1, 0, '_particle.group_id', '_particle.defocus';
		foreach (@{$self->{_particleData}}) {
			splice @{$_}, 1, 0, 1, 0;
		}
		# convert header
		my @newHeader = ();
		for (my $i = 0; $i <= $#{$self->{_header}}; $i++) {
			if ($self->{_header}->[$i]->[0] eq '_micrograph.id') {
				push (@newHeader, ['_map.3D_reconstruction.id', $self->{_header}->[$i]->[1]]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.file_name') {
				push (@newHeader, ['_map.3D_reconstruction.file_name', $self->{_header}->[$i]->[1]]);
				push (@newHeader, ['_map.3D_reconstruction.select', 1]);
				push (@newHeader, ['_map.3D_reconstruction.fom', 0]);
				push (@newHeader, ['_map.3D_reconstruction.origin_x', 0]);
				push (@newHeader, ['_map.3D_reconstruction.origin_y', 0]);
				push (@newHeader, ['_map.3D_reconstruction.origin_z', 0]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.x_scale') {
				push (@newHeader, ['_map.3D_reconstruction.scale_x', $self->{_header}->[$i]->[1]]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.y_scale') {
				push (@newHeader, ['_map.3D_reconstruction.scale_y', $self->{_header}->[$i]->[1]]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.z_scale') {
				push (@newHeader, ['_map.3D_reconstruction.scale_z', $self->{_header}->[$i]->[1]]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.pixel_size') {
				push (@newHeader, ['_map.3D_reconstruction.voxel_size', $self->{_header}->[$i]->[1]]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.box_radius_x') {
				push (@newHeader, ['_particle.box_radius_x', $self->{_header}->[$i]->[1]]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.box_radius_y') {
				push (@newHeader, ['_particle.box_radius_y', $self->{_header}->[$i]->[1]]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.box_radius_y') {
				push (@newHeader, ['_particle.box_radius_z', $self->{_header}->[$i]->[1]]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.bad_radius') {
				push (@newHeader, ['_particle.bad_radius', $self->{_header}->[$i]->[1]]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.filament_width') {
				push (@newHeader, ['_filament.width', $self->{_header}->[$i]->[1]]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.filament_node_radius') {
				push (@newHeader, ['_filament.node_radius', $self->{_header}->[$i]->[1]]);
				push (@newHeader, ['_refln.radius', 0]);
			}
			if ($self->{_header}->[$i]->[0] eq '_micrograph.marker_radius') {
				push (@newHeader, ['_marker.radius', $self->{_header}->[$i]->[1]]);
			}
		}		
		push (@newHeader, ['_map.view_x', 0]);
		push (@newHeader, ['_map.view_y', 0]);
		push (@newHeader, ['_map.view_z', 1]);
		push (@newHeader, ['_map.view_angle', 0]);
		$self->{_header} = \@newHeader;
		$self->{_version} = '1.6';	
	}
	return $self;
}

# Write bstar to file
sub write_bstar {
	my ($self, $starOutputFile) = @_;
	
	if ($self->{_version} eq '1.3') {
		$self->convert_to_bstar1_6();
	}
	
	open(FILEHDL, ">$starOutputFile") || die ("Cannot create file $starOutputFile. $!\n");
   select FILEHDL;
    
   # Write init
   print "\# Written by Bstar1_6.pm\n\n";
   print "data_", $self->{_name}, "\n\n";
       
   # Write header
   foreach (@{$self->{_header}}) {
    	if ($_->[0] eq '_map.3D_reconstruction.id') {
    		printf ("%-40s%s\n", $_->[0], $_->[1]);
    	} elsif ($_->[0] eq '_map.3D_reconstruction.file_name') {
    		printf ("%-40s%s\n", $_->[0], $_->[1]);
    	} else {
    		printf("%-40s%-.6f\n", $_->[0], $_->[1]);
    	}
	}
   print "\n";
    
   # Print particle field
   print "loop_\n";
   foreach (@{$self->{_particleFields}}) {
       print "$_\n";
   }    
   # Print particle data
   foreach (@{$self->{_particleData}}) {
       printf ("%4d %5d %5d %5.4f %6.2f %6.1f %6.2f %6.2f %6.2f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %1d\n", @{$_}); 
   }
   print "\n";
   
   if (defined $self->{_particleBad}) {
   	print "\n";
   	print "loop_\n_particle.bad_x\n_particle.bad_y\n_particle.bad_z\n";
   	foreach (@{$self->{_particleBad}}) {
   		printf(" %.2f %.2f %.2f\n", @{$_});
   	}
   	print "\n";   	
   }
   
   select STDOUT;
	close FILEHDL;

	return 1;
}

# Sub WRITE_BSTAR
# write only a selected record
sub write_selected_records {
	my ($self, $records, $starOutputFile) = @_;
	
	if ($self->{_version} eq '1.3') {
		$self->convert_to_bstar1_6();
	}
	
	open(FILEHDL, ">$starOutputFile") || die ("Cannot create file $starOutputFile. $!\n");
   select FILEHDL;
    
   # Write init
   print "\# Written by Bstar1_6.pm\n\n";
   print "data_", $self->{_name}, "\n\n";
       
   # Write header
   foreach (@{$self->{_header}}) {
    	if ($_->[0] eq '_map.3D_reconstruction.id') {
    		printf ("%-40s%s\n", $_->[0], $_->[1]);
    	} elsif ($_->[0] eq '_map.3D_reconstruction.file_name') {
    		printf ("%-40s%s\n", $_->[0], $_->[1]);
    	} else {
    		printf("%-40s%-.6f\n", $_->[0], $_->[1]);
    	}
	}
   print "\n";
    
   # Print particle field
   print "loop_\n";
   foreach (@{$self->{_particleFields}}) {
       print "$_\n";
   }    
   # Print particle data
   my $i = 1;
   foreach (@{$records}) {
   	 my $no_of_items = $#{$self->{_particleData}->[$_]};
       printf ("%4d %5d %5d %5.4f %6.2f %6.1f %6.2f %6.2f %6.2f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %1d\n", $i++, @{$self->{_particleData}->[$_]}[1 .. $no_of_items]); 
       
   }
   print "\n";
   
   if (defined $self->{_particleBad}) {
   	print "\n";
   	print "loop_\n_particle.bad_x\n_particle.bad_y\n_particle.bad_z\n";
   	foreach (@{$self->{_particleBad}}) {
   		printf(" %.2f %.2f %.2f\n", @{$_});
   	}
   	print "\n";   	
   }
   
   select STDOUT;
	close FILEHDL;

	return 1;
}

sub read_transform_file {
	# TO DO later
	my ($self, $transformFile) = @_;
	my @transformList = get_transform_list_from_doc($transformFile);

    if ($#{$self->{_particleData}} != $#transformList) {
        print "Transform list does not have equal record\n";          
        return 0;
    }

	$self->{_transformList} = \@transformList;
	#print Dumper($self->{_transformList});
	return $self->{_transformList};
}

# Copy bstar
sub copy {
	my ($self) = shift;

	my $newBstar = Bstar->new();
	
	# Copy name
	$newBstar->{_name} = $self->{_name};

	# Copy header
    foreach (@{$self->{_header}}) {    		
			push (@{$newBstar->{_header}},[$_->[0], $_->[1]]);
	}

	# Copy particle field
	my @particleFields = ();
    foreach (@{$self->{_particleFields}}) {
		push (@{$newBstar->{_particleFields}}, $_);
	}

	# Copy particle data
	my @particleData = ();
	if (defined $self->{_particleData}) {
		@particleData = map { [@$_] } @{$self->{_particleData}}; # Copy one layer
		$newBstar->{_particleData} = \@particleData;
	}
	
	my @particleBad = ();
	if (defined $self->{_particleBad}) {
		@particleBad = map { [@$_] } @{$self->{_particleBad}};
		$newBstar->{_particleBad} = \@particleBad;
	}
	
	# transform list
	my @transformList = ();
	if (defined $self->{_transformList}) {
		@transformList = map { [@$_] } @{$self->{_transformList}};
		$newBstar->{_transformList} = \@transformList;
	}	
	return $newBstar;
}

# Function to calculate the new Star file with corrected origin from original
# origins and transform
sub new_origins {
	my $self = shift;
	my $newBstar = $self->copy();
	print $self->{_version},"\n";
	if (!defined $newBstar->{_particleData}) {
		print "No particle data available\n";
		exit;
	}

	if (!defined $newBstar->{_transformList}) {
		print "No transform list available\n";
		exit;
	}

    my $i = 0;
    foreach (@{$newBstar->{_transformList}}) {
        my $rot = [$_->[0], $_->[1], $_->[2]];
        my $shift = [-$_->[3], -$_->[4], -$_->[5]];       
        my ($revShift, $revRot) = reverse_transform($rot, $shift);
        #print "$self->{_particleData}->[$i]->[1] $self->{_particleData}->[$i]->[2] $self->{_particleData}->[$i]->[3]\n"; 
        $newBstar->{_particleData}->[$i]->[4] = round($newBstar->{_particleData}->[$i]->[4] + $revShift->[0]);
        $newBstar->{_particleData}->[$i]->[5] = round($newBstar->{_particleData}->[$i]->[5] + $revShift->[1]);
        $newBstar->{_particleData}->[$i]->[6] = round($newBstar->{_particleData}->[$i]->[6] + $revShift->[2]);
		  $_->[0] = 0;
        $_->[1] = 0;
        $_->[2] = 0;
        $i++;
    }  
	return $newBstar;
}

sub write_imod_point {
	my ($self, $pointOutputFile) = @_;

	open(FILEHDL, ">$pointOutputFile") || die ("Cannot create file $pointOutputFile. $!\n");
    select FILEHDL;
    
    # Write init
    #print "\# Written by Bstar.pm\n\n";
    #print "$self->{_name}\n\n";
       

    # Print point data
	my $objectId = 1;
	my $contourId = 1;
    foreach (@{$self->{_particleData}}) {
		my $orgX = round($_->[4]);
		my $orgY = round($_->[5]);
		my $orgZ = round($_->[6]);
		if ($orgX < 0) {
			$orgX = 0;
		}
		if ($orgY < 0) {
			 $orgY = 0;
		}
		if ($orgZ < 0) {
			 $orgZ = 0;
		}
        printf "%10d %10d %10d %10d %10d\n", $objectId, $contourId, $orgX, $orgY, $orgZ;
    }
    print "\n";

   select STDOUT;
	close FILEHDL;
	return 1;
}

sub get_number_of_particles {
	my $self = shift;
	if (defined $self->{_particleData}) {
		return $#{$self->{_particleData}} + 1;
	} else {
		return 0;
	}
} 

sub get_version {
	my $self = shift;
	if (defined $self->{_version}) {
		return $self->{_version};
	} else {
		return 0;
	}
}

sub set_header_item {
	my ($self, $key, $new_value) = @_;
	if (!(defined $self->{_header})) {
		return -1;
	}
	foreach (@{$self->{_header}}) {
		if ($_->[0] =~ /$key/i) {
			$_->[1] = $new_value;
			last;
		}
	}
	return 1;
}

sub get_header_item {
	my ($self, $key) = @_;
	if (!(defined $self->{_header})) {
		return undef;
	}
	foreach (@{$self->{_header}}) {
		if ($_->[0] =~ /$key/i) {
			return $_->[1];
		}
	}
	return undef;
}

sub get_particle_origin {
	my ($self, $particleIndex) = @_;
	if (($particleIndex < 1) || ($particleIndex > $self->get_number_of_particles())) {
		print "Particle Index must be between 1 and ", $self->get_number_of_particles(), "\n";
		return (0, 0, 0);	
	}
	return @{$self->{_particleData}->[$particleIndex - 1]}[4 .. 6];	
}

sub get_particle_transform {
	my ($self, $particleIndex) = @_;
	if (($particleIndex < 1) || ($particleIndex > $self->get_number_of_particles())) {
		print "Particle Index must be between 1 and ", $self->get_number_of_particles(), "\n";
		return (0, 0, 0, 0, 0, 0, 0);	
	}
	return @{$self->{_transformList}->[$particleIndex - 1]};	
}
sub DESTROY {
	my $self = shift;
}
1;
