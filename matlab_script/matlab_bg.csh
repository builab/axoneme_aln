#!/bin/csh
# Script to run matlab process in background

set OLDDISPLAY=$DISPLAY
unsetenv DISPLAY
nohup matlab < matlab_script.m > matlab_out.txt & 
setenv DISPLAY $OLDDISPLAY
