d=`date`
echo ----------------------------------------------------------------------------------- 
echo Running SSAKE assembly pipeline on bacterial sequence data.
echo ----------------------------------------------------------------------------------- 
echo Downloading MiSeq data for Campylobacter showae CC57C on $d ...
echo -----------------------------------------------------------------------------------
rm -rf Assemble_1_R*.fastq
wget ftp://ftp.bcgsc.ca/supplementary/SSAKE/Assemble_1_R*.fastq
echo -----------------------------------------------------------------------------------
echo done. Trimming low quality bases, be patient...
echo -----------------------------------------------------------------------------------
../tools/TQSfastq.py -f Assemble_1_R1.fastq -t 30 -c 100 -e 33
../tools/TQSfastq.py -f Assemble_1_R2.fastq -t 30 -c 100 -e 33
cat Assemble_1_R2.fastq_T30C100E33.trim.fa |perl -ne 'if(/^(\>\@\S+)/){print "$1b\n";}else{print;}' >Assemble_1_R2.fastq_T30C100E33.trimFIX.fa
cat Assemble_1_R1.fastq_T30C100E33.trim.fa |perl -ne 'if(/^(\>\@\S+)/){print "$1a\n";}else{print;}' >Assemble_1_R1.fastq_T30C100E33.trimFIX.fa
echo -----------------------------------------------------------------------------------
echo done. Formatting fasta input for SSAKE...
echo -----------------------------------------------------------------------------------
../tools/makePairedOutput2UNEQUALfiles.pl Assemble_1_R1.fastq_T30C100E33.trimFIX.fa Assemble_1_R2.fastq_T30C100E33.trimFIX.fa 400
echo -----------------------------------------------------------------------------------
echo done. Initiating SSAKE assembly ETA 10-20min depending on system...
echo -----------------------------------------------------------------------------------
time ../SSAKE -f paired.fa -p 1 -g unpaired.fa -m 20 -w 5 -b Cshowae
echo -----------------------------------------------------------------------------------
echo done. Computing stats from contigs 
echo -----------------------------------------------------------------------------------
../tools/getStats.pl Cshowae_contigs.fa 500 > Cshowae_contigs_stats.fa
echo done. Computing stats from scaffolds
echo -----------------------------------------------------------------------------------
../tools/getStats.pl Cshowae_scaffolds.fa 500 > Cshowae_scaffolds_stats.txt
echo assembly pipeline complete. Results are under Cshowae.
