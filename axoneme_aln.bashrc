#!/bin/bash

export AA_DIR=/storage/software/axoneme_aln
export PATH=$AA_DIR/perl:$PATH
export PATH=/storage/software/MATLAB/R2020a/bin:$PATH
export PATH=/storage/software/scipion_1.2/software/em/spider-21.13/spider/bin:$PATH

#export PERL5LIB=/storage/labusr/perl_lib/lib

if ($PERL5LIB) then
	PERL5LIB=$AA_DIR/perl/lib:$PERL5LIB
else
	PERL5LIB=$AA_DIR/perl/lib
fi

PERL5LIB=/storage/software/axoneme_aln/perl/lib/perl5/site_perl/5.8.8:$PERL5LIB
PERL5LIB=/storage/software/axoneme_aln/perl/lib/x86_64-linux-gnu/perl/5.26.1:$PERL5LIB

export PERL5LIB

source /storage/software/bsoft_1.8.6/bsoft.bashrc 
export PATH=/storage/software/perl_scripts/subtomo:$PATH
export PATH=/storage/software/perl_scripts:$PATH
