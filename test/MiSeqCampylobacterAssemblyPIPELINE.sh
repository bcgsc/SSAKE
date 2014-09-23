d=`date`
echo ----------------------------------------------------------------------------------- 
echo Running SSAKE assembly pipeline on bacterial sequence data. It will need ca.4GB RAM
echo ----------------------------------------------------------------------------------- 
echo Downloading miseq data for Campylobacter showae on $d ...
echo -----------------------------------------------------------------------------------
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
echo done. Converting scaffold .csv into fasta file...
echo -----------------------------------------------------------------------------------
../tools/makeFastaFileFromScaffolds.pl Cshowae.scaffolds
echo -----------------------------------------------------------------------------------
echo done. Computing stats from Cshowae.contigs 
echo -----------------------------------------------------------------------------------
../tools/getStats.pl Cshowae.contigs > Cshowae.contigs.stats
echo -----------------------------------------------------------------------------------
echo done. Computing stats from Cshowae.scaffolds.fa
echo -----------------------------------------------------------------------------------
../tools/getStats.pl Cshowae.scaffolds.fa > Cshowae.scaffolds.stats
echo assembly pipeline complete. Results are under Cshowae.
