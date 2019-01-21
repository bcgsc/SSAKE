d=`date`
echo ----------------------------------------------------------------------------------- 
echo Running SSAKE assembly pipeline on bacterial sequence data 250X E.coli
echo ----------------------------------------------------------------------------------- 
rm -rf ecoli_miseqTrimmed*fa
wget http://www.bcgsc.ca/downloads/supplementary/SSAKE/ecoli_miseqTrimmed_paired.fa
wget http://www.bcgsc.ca/downloads/supplementary/SSAKE/ecoli_miseqTrimmed_unpaired.fa
echo -----------------------------------------------------------------------------------
echo done. Initiating SSAKE assembly ETA 20-30min depending on system...
echo -----------------------------------------------------------------------------------
/usr/bin/time -v -o coliMiSeq300m80.time ../SSAKE -f ecoli_miseqTrimmed_paired.fa -g ecoli_miseqTrimmed_unpaired.fa -p 1 -m 80 -w 100 -b coliMiSeq300m80
echo -----------------------------------------------------------------------------------
echo done. Computing stats from contigs 
echo -----------------------------------------------------------------------------------
../tools/getStats.pl coliMiSeq300m80_contigs.fa > coliMiSeq300m80_contigs_stats.txt
echo -----------------------------------------------------------------------------------
echo done. Computing stats from scaffolds
echo -----------------------------------------------------------------------------------
../tools/getStats.pl coliMiSeq300m80_scaffolds.fa 200 > coliMiSeq300m80_scaffolds_200bpstats.txt
../tools/getStats.pl coliMiSeq300m80_scaffolds.fa 500 > coliMiSeq300m80_scaffolds_500bpstats.txt
echo assembly pipeline complete. Results are under coliMiSeq300m80.
