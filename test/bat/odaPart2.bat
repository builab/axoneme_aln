./bat/refinedAln.bat
./bat/cbnDoc.bat > cbnDoc.log
nohup batch_job_submit.pl 1 ./bat/interAln.bat > interAln.log
./bat/cbnAllDoc.bat > cbnAllDoc.log
nohup batch_job_submit.pl 1 ./bat/avg.bat > avg.log
./bat/calcMwWeight.bat
./bat/weightedAvg.bat
