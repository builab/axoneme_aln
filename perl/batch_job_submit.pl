#!/usr/bin/perl -w
# Script to control parallel jobs from a batch script
# HB 20080130
# Last modified: 20081103
# + signal to stop parallel #END_PARALLEL

use Parallel::ForkManager;
use LWP::Simple;

if ($#ARGV < 1) {
	print "Usage: batch_job_submit.pl num_of_processors bat_file\n";
	print "Example: batch_job_submit.pl 4 auto_aln_chlamy.bat\n";
	exit;
}

$MAX_PROCESSES = $ARGV[0]; # Max no. of processes = max no. of cpus
$batch_file = $ARGV[1];

open (FILEHDL, "$batch_file") || die "Cannot open $batch_file . $!\n";

@job_list = <FILEHDL>;

close FILEHDL;

$pm = new Parallel::ForkManager($MAX_PROCESSES);

my $i = 0;
for (; $i <= $#job_list; $i++) { 
#foreach my $job (@job_list) {
	my $job = $job_list[$i];
	if ($job =~ /^\#END_PARALLEL/i) {print "End running parallel\n"; last; }
	if ($job =~ /^\#/i) { next; }
	if ($job =~ /^\s*$/i) {next; }
	$pm->start and next; # do the fork
	chomp $job;
	print "$job\n";
	system($job);
	$pm->finish;
}
$pm->wait_all_children;

for (; $i <= $#job_list; $i++) {
	my $job = $job_list[$i];
	if ($job =~ /^\#/i) { next; }
        if ($job =~ /^\s*$/i) {next; }
	chomp $job;
	print "$job\n";
	system($job);
}

exit;
