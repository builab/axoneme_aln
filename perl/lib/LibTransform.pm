package LibTransform;

# functions for transformation
#	sub euler_to_matrix3 OK
#	sub matrix3_to_euler OK
#	sub reverse_transform OK
#	sub combine_transform OK
#	sub combine_long_transform OK
#	sub deg2rad OK
#	sub rad2deg OK
#	sub round OK

#	16/03 HB
#  19/03 Fix reverse_transform & combine_transform
#  Add view option

use strict;
use warnings;
use Data::Dumper;

use Math::MatrixReal;
use POSIX;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(euler_to_matrix3 matrix3_to_euler reverse_transform 
				combine_transform deg2rad rad2deg round combine_transform_list combine_long_transform get_transform_list_from_doc);
@EXPORT_OK = qw(min max);
%EXPORT_TAGS = (all => [@EXPORT_OK]);
$VERSION = '0.1';

my $M_PI = 3.14159265358979323846264338327950288;
my $SMALLFLOAT = 1e-14;

#################
# Function
#################

# From phi, theta, psi angle to rotational $ma3rix
sub euler_to_matrix3{
	my ($phi, $theta, $psi) = @_;
	$psi = deg2rad($psi);
	$phi = deg2rad($phi);
	$theta = deg2rad($theta);
	my $rot_psi = Math::MatrixReal->new_from_rows([[cos($psi), sin($psi), 0],
																 [-sin($psi), cos($psi), 0],
																 [0, 0, 1]]);
	my $rot_theta = Math::MatrixReal->new_from_rows([[cos($theta), 0, -sin($theta)],
																 [0, 1, 0],
																 [sin($theta), 0, cos($theta)]]);
	my $rot_phi = Math::MatrixReal->new_from_rows([[cos($phi), sin($phi), 0],
																 [-sin($phi), cos($phi), 0],
																	 [0, 0, 1]]);

	my $tmp = $rot_psi->multiply($rot_theta);
	my $matrix3 = $tmp->multiply($rot_phi);

	return $matrix3;
}

# Convert from a rotational $ma3rix back to euler angles
sub matrix3_to_euler{
	my ($ma3) = shift;
	
	my $theta = acos($ma3->element(3,3));
	my ($phi, $psi);

	if ($theta < $SMALLFLOAT) {
		$phi = 0;
		$psi = atan2(-$ma3->element(2,1),$ma3->element(1,1));
	} elsif (abs($theta - $M_PI) < $SMALLFLOAT) {
		$phi = 0;
		$psi = atan2($ma3->element(2,1),-$ma3->element(1,1));
	} else {
		$phi = atan2($ma3->element(3,2), $ma3->element(3,1));
		$psi = atan2($ma3->element(2,3), -$ma3->element(1,3));
	}

	$phi = rad2deg($phi);
	$theta = rad2deg($theta);
	$psi = rad2deg($psi);
	
	return ($phi, $theta, $psi);
}

# Reverse from rotate, sh to sh, rotate
# R*X + S = R'(*X + S') => R' = R; S' = R^-1*S
sub reverse_transform {
	my ($rt, $sh) = @_;

	my $rt_ma3 = euler_to_matrix3(@{$rt});

	my $rt_inverse = $rt_ma3->inverse();
	my $sh_rev_ma = $rt_inverse->multiply(Math::MatrixReal->new_from_cols([$sh]));
	my $sh_rev = [$sh_rev_ma->element(1,1), $sh_rev_ma->element(2,1), $sh_rev_ma->element(3,1)];

	my $rt_rev = \@$rt;
	return ($sh_rev, $rt_rev);
}

sub combine_transform {
	# 2 sets of (rotate, shift) are combined to get one transform (rotate, shift)
	# R2*(R1*X+T1) + T2 = RX + T
	# => R = R2*R1; T = R2*T1 + T2;
	my ($r1, $t1, $r2, $t2) = @_;
	my $r2_ma = euler_to_matrix3(@$r2);
	my $r_matrix = $r2_ma->multiply(euler_to_matrix3(@$r1));
	my @r = matrix3_to_euler($r_matrix);
	my $t_ma = new Math::MatrixReal(3,1);
	$t_ma->add($r2_ma->multiply(Math::MatrixReal->new_from_cols([$t1])),Math::MatrixReal->new_from_cols([$t2]));
	
	my $t = [$t_ma->element(1,1), $t_ma->element(2,1), $t_ma->element(3,1)];
	return (\@r, $t);
}

sub combine_long_transform {
	my ($tf1, $tf2) = @_;	
	my @r1 = ($tf1->[0], $tf1->[1], $tf1->[2]);
	my @t1 = ($tf1->[3], $tf1->[4], $tf1->[5]);
	my @r2 = ($tf2->[0], $tf2->[1], $tf2->[2]);
	my @t2 = ($tf2->[3], $tf2->[4], $tf2->[5]);
	my ($r, $t) = combine_transform(\@r1, \@t1, \@r2, \@t2);
	return [$r->[0], $r->[1], $r->[2], $t->[0], $t->[1], $t->[2]];
}

sub deg2rad {
	my ($degree) = @_;
	my $rad = $degree * $M_PI / 180;
	return $rad;
}

sub rad2deg {
	my ($rad) = @_;
	my $degree = $rad * 180 / $M_PI;
	return $degree;
}

sub round {
    my($number) = @_;
	return int($number + .5 * ($number <=> 0));
}

sub get_transform_list_from_doc {
	my ($docFile) = shift;
	open (FILEHDL, "$docFile") || die "Cannot open $docFile. $!\n";	
	my $index = 0;
	my @transformList;
	while (<FILEHDL>) {
		chomp;
		if (/;/i) { next; }
		#print "$_\n";
		my @line = split(" ", $_);
		$transformList[$index++] = [$line[2], $line[3], $line[4], $line[5], $line[6], $line[7], $line[8]];
	}

	close FILEHDL;
	return @transformList;
}

sub combine_transform_list {
	my ($list1, $list2) = @_;
	my $lenList1 = $#{$list1} + 1;
	my $lenList2 = $#{$list2} + 1;
	#print "$lenList1 $lenList2\n";
	if ( !( ($lenList1 == 1) || ($lenList2 == 1) ) ) {
		if (!($lenList1 == $lenList2)) {
			print "Lists do not contain the same record number\n";
			return -1;
		}
	}
	my $num_of_records = $lenList1;
	if ($lenList1 < $lenList2) {
		$num_of_records = $lenList2;
	} 
	my @cbn_list;
	my $indexList1 = 0;
	my $indexList2 = 0;
	for (my $i = 0; $i < $num_of_records; $i++) {
		my $ccc = 0;
		if ($lenList1 > $lenList2) {
			$indexList1 = $i;
			$indexList2 = 0;
			$ccc = $list1->[$indexList1]->[6];
		} elsif ($lenList1 < $lenList2) {
			$indexList1 = 0;
			$indexList2 = $i;
			$ccc = $list2->[$indexList2]->[6];
		} else {
			$indexList1 = $i;
			$indexList2 = $i;
			$ccc = $list2->[$indexList2]->[6];
		}
		if ($ccc eq 'NaN') {
			$ccc = 0;
		}	
		my $cbn_xform = combine_long_transform($list1->[$indexList1], $list2->[$indexList2]);		

		$cbn_list[$i] = [$cbn_xform->[0], $cbn_xform->[1], $cbn_xform->[2], $cbn_xform->[3], $cbn_xform->[4], $cbn_xform->[5], $ccc];
	}
	return \@cbn_list;
}

sub write_transform_list_to_spider_doc {
	
}

#-------------------
# Matrix 3 from view
#-------------------
sub matrix3_from_view {
	return 1;
}
#-------------------
# view from matrix3
#-------------------
sub view_from_matrix3 {
	return 1;
}

1;
