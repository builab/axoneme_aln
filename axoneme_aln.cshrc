#!/bin/tcsh -f

setenv AA_DIR /mol/ish/Data/programs/aa_test/axoneme_aln
setenv PATH "${PATH}:$AA_DIR/perl"

if ($?PERL5LIB) then
	setenv PERL5LIB "${PERL5LIB}:$AA_DIR/perl/lib"
else
	setenv PERL5LIB "$AA_DIR/perl/lib"
endif

setenv PERL5LIB "${PERL5LIB}:$AA_DIR/perl/lib/perl5/site_perl/5.8.8"
