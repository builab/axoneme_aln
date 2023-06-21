./bat/initFit.bat
./bat/initDoc.bat
nohup batch_job_submit.pl 1 ./bat/intraAln.bat > intraAln.log
./bat/roughAln.bat
