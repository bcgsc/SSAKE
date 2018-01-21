d=`date`
echo ----------------------------------------------------------------------------------- 
echo Running SSAKE assembly pipeline on bacterial sequence data. It will need ca.80GB RAM
echo ------------------------------------------------------------------------------------ 
echo Downloading trimmed/formatted data on $d ...
echo ------------------------------------------------------------------------------------
rm -rf celegans_paired.fa
wget ftp://ftp.bcgsc.ca/supplementary/SSAKE/celegans_paired.fa.gz
gunzip celegans_paired.fa.gz
echo ------------------------------------------------------------------------------------
echo done. Initiating SSAKE assembly ETA 4h depending on system...
echo ------------------------------------------------------------------------------------
time ../SSAKE -f celegans_paired.fa -p 1 -m 20 -w 5 -b celegansLR
echo ------------------------------------------------------------------------------------
echo done. Computing stats from contigs
echo ------------------------------------------------------------------------------------
../tools/getStats.pl celegansLR_contigs.fa 500 > celegansLR_contigs_stats.txt
echo done. Computing stats from scaffolds 
echo ------------------------------------------------------------------------------------
../tools/getStats.pl celegansLR_scaffolds.fa 500 > celegansLR_scaffolds_stats.txt
echo assembly pipeline complete. Results are under celegansLR.
