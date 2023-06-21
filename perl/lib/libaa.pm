package libaa;

# Function lib for AA scripts
# HB 2008/11/11
# 	readParams
# 	writeParams
#	getInput
#	createDir
#	notifyError
#	parseList
#   writeList
#   writeTemplate2MScript
#   printMenu
# @update printMenu 20091018

use strict;
use warnings;
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(readParams writeParams getInput getInputPersistence createDir notifyError parseList writeList printMenu parseSeq);
@EXPORT_OK = qw(min max);
%EXPORT_TAGS = (all => [@EXPORT_OK]);
$VERSION = '0.1';


sub readParams {
	my ($paramFile) = shift;
	eval {
		open(FILEHDL, "$paramFile") || die "Cannot open $paramFile. $!\n";
	};

	if ($@) { print $@; return 0};
	#print "Parsing $paramFile\n";
	my %params = ();
	while (<FILEHDL>) {
		chomp;
		if (/^\#/i) {
			next;
		}
		if (/^(\S*)=(\S*)$/) {
			$params{$1} = $2;
			#printf "\t%20s   %s\n", $1, $2;
		}
	}
	close FILEHDL;
	return %params;	
}

sub writeParams {
	my ($params, $paramFile) = @_;
	my %params = %{$params};
	
	eval {
		open(FILEHDL, ">$paramFile") || die "Cannot open $paramFile. $!\n"; 
	};

	if ($@) { print $@; return 0;}

	# Write time
    my $currtime = time();
    my @timelist = localtime($currtime);
    my $year = $timelist[5] + 1900;
	my $month = $timelist[4]+1;
	print FILEHDL "\#$timelist[3]-$month-$year  $timelist[2]:$timelist[1]:$timelist[0]\n";

	foreach my $key (sort {$a cmp $b} (keys %params)) {
		print FILEHDL "$key=$params{$key}\n";
	}		
	close FILEHDL;
	return 1;
}

sub parseList {
    my ($listFile) = shift;
    my %list = ();
    open (FILEHDL, $listFile) || die "Cannot open $listFile. $!";
    while (<FILEHDL>) {
        if (/\#/) { next;}
		if (/^\s*$/) { next;}
        if (/^\s*(\S+)\s+(\S+)\s+\d/i) {
            $list{$2} = $1;
        }
    }
    close FILEHDL;

    return %list;
}

sub getInput {
	my ($question, $defaultAnswer) = @_;
	if (!(defined $defaultAnswer)) {
		$defaultAnswer = '';
	}
	print "$question [$defaultAnswer]: ";
	chomp (my $input = <>);
	if ($input =~ /^\S+$/i) {
		return $input;
	}
	return $defaultAnswer;
}

sub getInputPersistence {
	my ($question, $defaultAnswer) = @_;

	while (1) {
		my $input = getInput($question, $defaultAnswer);
		if (-e $input) {
			return $input;
		}
		print "\n$input does NOT exist!! Re-enter!!\n";
	}	
}

sub notifyError {
	my ($errorMsg) = shift;
	print "$errorMsg\n";
	print "Program terminated!!!\n";
	exit (1);
}	

sub createDir {
	my ($dir) = @_;
	eval {
	if (-d $dir) {
		print "\t$dir already exists\n";
	} else {
		print "\tmkdir $dir\n";
		mkdir ($dir) || die "Cannot create $dir. $!\n";
	} 
    };
	if ($@) { print $@; return 0;};
	return 1;
}

sub parseListNew {
    my ($listFile) = shift;
    my %list = ();
    open (FILEHDL, $listFile) || die "Cannot open $listFile. $!";
    while (<FILEHDL>) {
        if (/\#/) { next;}
		if (/^\s*$/) { next;}
        if (/^\s*(\S+)\s+(\S+)\s+(\d)/i) {
            $list{$2} = $1;
			$list{"$2_flaDirect"} = $3;
        }
    }
    close FILEHDL;

    return %list;
}

sub writeList {
	my ($list, $listFile) = @_;

	my %list = %{$list};
	eval {
		open(LSTHDL, ">$listFile") || die "Cannot create $listFile. $!";
	};
	if ($@) { print $@; return 0;}
	
	# Write time
    my $currtime = time();
    my @timelist = localtime($currtime);
    my $year = $timelist[5] + 1900;
	my $month = $timelist[4]+1;
	print LSTHDL "\#$timelist[3]-$month-$year  $timelist[2]:$timelist[1]:$timelist[0]\n";

	foreach (sort {$a cmp $b} (keys %list)) {
		if (~/_flaDirect/i) {
			next;
		}
		my $flaKey = $_ . '_flaDirect';
		my $line = sprintf("%-12s %10s %4s\n", $list{$_}, $_, $list{$flaKey});
		printf "\t$line";
		printf LSTHDL $line;
	}
	close LSTHDL;
	return 1;
}

sub writeTemplateToMScript {
	my ($scriptFile, $templateFile, $paramFile) = @_;

	my %params = readParams($paramFile);

	#print Dumper(%params); # DEBUG
	my $batchFile = $scriptFile;
	$batchFile =~ s/\.m$/\.bat/i;
	my $logFile = $batchFile;
	$logFile =~ s/^.*\/(.*)\.bat$/$1\.log/g;

	open (INHDL, $templateFile) || die "Cannot open $templateFile. $!\n";
	open (OUTHDL, ">$scriptFile") || die "Cannot create $scriptFile. $!\n";
	open (OUT2HDL, ">$batchFile") || die "Cannot create $batchFile. $!\n";

	my $headerEnd = 0;
	my $headerStart = 0;
	while (<INHDL>) {
		if (/START HEADER/) {
			$headerStart = 1;
			next;
		}
		if (/END HEADER/) {
			$headerEnd = 1;
			next;
		}

		if ($headerEnd || !$headerStart) {
			print OUTHDL $_;
		} else {
			foreach my $key (keys %params) {
				if (/\#s\#$key\#/i) {
					#print "$params{$key}\n"; # DEBUG
					$_ =~ s/\#s\#$key\#/\'$params{$key}\'/i;
					print OUTHDL $_;
					next;
				} elsif (/\#d\#$key\#/i) {
					#print "$params{$key}\n"; # DEBUG
					$_ =~ s/\#d\#$key\#/$params{$key}/i;
					print OUTHDL $_;
					next;	
				}				
			}	
		}
	}

	print OUT2HDL"nohup matlab -nodisplay < $scriptFile > $logFile\n";

	close INHDL;
	close OUTHDL;
	close OUT2HDL;

	&finishWriting($batchFile);

	return 1;
}

#---------------------------
# Print menu
#---------------------------
sub printMenu {
	my ($mainMenu, $addMenu) = @_;
	my $count = 1;
	my $itemPerLine = 4;

	printf "\n\t%-16s\n\n", "MAIN SCRIPTS";
	printf "\t%16s\n\t", "All [0]";

	foreach (sort {$a <=> $b} keys (%{$mainMenu})) {
		if ($count > $itemPerLine) {
			print "\n\t";
			$count = 1;
		}
		my $item = $mainMenu->{$_} . '[' . $_ . ']';
		printf "%16s ", $item;
		$count++;
	}
	
	printf "\n\n\t%-16s\n\n", "ADDITIONAL SCRIPT";
	foreach (sort {$a <=> $b} keys (%{$addMenu})) {
		my $item = $addMenu->{$_} . '[' . $_ . ']';
		printf "\t%16s\n", $item;
	}
	printf "\n\t%-16s\n\n", "TO STOP [done]";
	return 1;
	
}
#---------------------------
# Change mod of script to +x & notify
#---------------------------
sub finishWriting {
	my ($scriptFile) = shift;
	chmod 0750, $scriptFile;
	print "\t$scriptFile created\n";
	return 1;
}

#---------------------------
# Parse a sequence of number
# Eg.: 1,3-5,10 -> 1,3,4,5,10
#---------------------------
sub parseSeq {
	my $seq = shift;
	my @list = split(',', $seq);
	my @new_list = ();

	foreach (@list) {
		if (/-/i) {
		my @sub_list = split('-', $_);
		for (my $j = $sub_list[0]; $j <= $sub_list[1]; $j++) {
			push(@new_list, $j);
		}
	} else {
		push(@new_list, $_);
	}
	return @new_list;
}

}
1;
