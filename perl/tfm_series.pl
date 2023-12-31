#!/usr/bin/perl -w
# Writing a read_spi_doc.soc file & run it
# Usage: ./tfm_series.pl -u series_name start end output doc_file
# HB 15/05/07
# @lastmod 02/09/07 remove tmp file, autoname generator

$is_uniform = 0;

if ($#ARGV < 4) {
	&print_usage;
	exit;
}

if ($ARGV[0] eq '-u') {
	$is_uniform = 1;
} elsif ($ARGV[0] eq '-nu') {
	$is_uniform = 0;
} else {
	&print_usage;
	exit;
}

if ($#ARGV < 5) {
	&print_usage;
	exit;
}

$series_name = $ARGV[1];
$start = $ARGV[2];
$end = $ARGV[3];
$output = $ARGV[4];
$doc_file = $ARGV[5];
$doc_file =~ s/\.spi$//g;
# Random Id
@chars = ("a" .. "z", 0 .. 9);
$rand_id = join("", @chars[map {rand @chars} (1 .. 4)]);

$soc_script = 'tfm_series_'.$rand_id;


&print_tfm_series($is_uniform, $series_name, $start, $end, $output, $doc_file);

print "Running\n";
print "spider  soc/spi \@$soc_script\n\n";
system("spider", "soc/spi", "\@$soc_script");
print "\nRunning complete\n";
print "rm ${soc_script}.soc\n";
system("rm ${soc_script}.soc");

exit;
#################
sub print_usage {
	print "Usage:\n";
	print "    ./tfm_series.pl -u series_name start end output doc_file\n";
	print "    ./tfm_series.pl -nu series_name start end output doc_file\n";
	print "Flag: -u uniform transform, -nu non-uniform transform \n";
}

sub print_tfm_series {
	my ($is_uniform, $series_name, $start, $end, $output, $doc_file) = @_;

	open(OUTHDL, ">${soc_script}.soc") || die ("Error opening file $\!\n");
	select OUTHDL;


	# Printing simple_avg.soc content
	print " ; <html><head><title>Alignment dynein/MTs</title></head><body><pre>\n";
	print " ;\n";
	print " ; PURPOSE: Transform a series using transform from a document\n";
	print " ; SOURCE: tfm_series.soc (Generated by tfm_series.pl)\n";
	print " ;\n";
	print " ; Date: 15/05/07\n";
	print " ; \n\n";
 
	print " ; ------------ Input files --------------------------\n\n";
	print "FR G\n[input]$series_name\{***x50\} \n\n";
	print "FR G\n[doc]$doc_file\n\n";
	print "FR G\n[output]$output\{***x50\}\n\n";

	print " ; ---------------- Transform ------------------------\n\n";

	if ($is_uniform) {
		print "x20=1\n";
		print "UD x20,x21,x22,x23,x24,x25,x26\n[doc]\n\n";
	}

	print "DO LB1 x50=$start,$end\n";
	
	print "   x51=x50-$start+1\n\n";

	if (!$is_uniform) {
		print "UD x51,x21,x22,x23,x24,x25,x26\n[doc]\n\n";
	}

	print "   ; produce output\n\n";
	print "   RT 3D\n   [input]\n   _1\n   x21,x22,x23\n\n";
	print "   SH F\n   _1\n   [output]\n   x24,x25,x26\n\n";

	print "LB1\n\n";

	print "EN D    ; end of procedure\n\n";

	print " ; </body></pre></html>\n\n";

	select STDOUT;
	close OUTHDL;

	return 1;
}
