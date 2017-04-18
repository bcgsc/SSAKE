d=`date`
echo ----------------------------------------------------------------------------------- 
echo Running SSAKE assembly pipeline on bacterial sequence data 250X E.coli
echo ----------------------------------------------------------------------------------- 
echo -----------------------------------------------------------------------------------
rm -rf ecoli_miseqTrimmed*fa
wget ftp://ftp.bcgsc.ca/supplementary/SSAKE/ecoli_miseqTrimmed_paired.fa
wget ftp://ftp.bcgsc.ca/supplementary/SSAKE/ecoli_miseqTrimmed_unpaired.fa
echo -----------------------------------------------------------------------------------
echo done. Initiating SSAKE assembly ETA 20-30min depending on system...
echo -----------------------------------------------------------------------------------
/usr/bin/time -v -o coliMiSeq300m80.time ../SSAKE -f ecoli_miseqTrimmed_paired.fa -g ecoli_miseqTrimmed_unpaired.fa -p 1 -m 80 -w 100 -b coliMiSeq300m80
echo -----------------------------------------------------------------------------------
echo done. Converting scaffold .csv into fasta file...
echo -----------------------------------------------------------------------------------
../tools/makeFastaFileFromScaffolds.pl coliMiSeq300m80.scaffolds
echo -----------------------------------------------------------------------------------
echo done. Computing stats from Ecoli.contigs 
echo -----------------------------------------------------------------------------------
../tools/getStats.pl coliMiSeq300m80.contigs > coliMiSeq300m80.contigs.stats
echo -----------------------------------------------------------------------------------
echo done. Computing stats from Ecoli.scaffolds.fa
echo -----------------------------------------------------------------------------------
../tools/getStats.pl coliMiSeq300m80.scaffolds.fa 200 > coliMiSeq300m80.scaffolds.200stats
../tools/getStats.pl coliMiSeq300m80.scaffolds.fa 500 > coliMiSeq300m80.scaffolds.500stats
echo assembly pipeline complete. Results are under coliMiSeq300m80.
