d=`date`
echo ----------------------------------------------------------------------------------- 
echo Running SSAKE assembly pipeline 
echo ----------------------------------------------------------------------------------- 
echo Downloading MiSeq data for Ebola on $d ...
echo -----------------------------------------------------------------------------------
rm -rf SRR2019530_*.fastq
wget ftp://ftp.bcgsc.ca/supplementary/SSAKE/SRR2019530_*.fastq
echo -----------------------------------------------------------------------------------
echo done. Trimming low quality bases, be patient...
echo -----------------------------------------------------------------------------------
echo SRR2019530_1.fastq > ebola.fof
echo SRR2019530_2.fastq >> ebola.fof
../tools/TQSfastq.pl -f ebola.fof -q 20 -n 70 -e 33 
cat SRR2019530_1.fastqc70q20e33.fa |perl -ne 'if(/^(\>\@\S+)/){print "$1b\n";}else{print;}' >SRR2019530_1.fastqc70q20e33.trimFIX.fa
cat SRR2019530_2.fastqc70q20e33.fa |perl -ne 'if(/^(\>\@\S+)/){print "$1a\n";}else{print;}' >SRR2019530_2.fastqc70q20e33.trimFIX.fa
echo -----------------------------------------------------------------------------------
echo done. Formatting fasta input for SSAKE...
echo -----------------------------------------------------------------------------------
../tools/makePairedOutput2UNEQUALfiles.pl SRR2019530_1.fastqc70q20e33.trimFIX.fa SRR2019530_2.fastqc70q20e33.trimFIX.fa 600
echo -----------------------------------------------------------------------------------
echo done. Initiating SSAKE assembly ETA 10-20min depending on system...
echo -----------------------------------------------------------------------------------
time ../SSAKE -f paired.fa -p 1 -g unpaired.fa -m 20 -w 5 -b ebola
echo -----------------------------------------------------------------------------------
echo done. Computing stats from ebola_contigs.fa 
echo -----------------------------------------------------------------------------------
../tools/getStats.pl ebola_contigs.fa 500 > ebola_contigs_stats.txt
echo done. Computing stats from ebola_scaffolds.fa
echo -----------------------------------------------------------------------------------
../tools/getStats.pl ebola_scaffolds.fa 500 > ebola_scaffolds_stats.txt
echo assembly pipeline complete. Results are under ebola.
