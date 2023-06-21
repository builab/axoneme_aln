#!/bin/tcsh -f

switch ($HOST)
	case "nazgul.mol.dbiol.d.ethz.ch"
		setenv PATH ${PATH}:/mol/imb/matlab/bin
		breaksw
	case "palu.mol.dbiol.d.ethz.ch"
		setenv PATH ${PATH}:/usr/local/bin
		breaksw
	default
		echo "Unknown host!"
endsw
