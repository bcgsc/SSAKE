d=`date`
echo ----------------------------------------------------------------------------------- 
echo Running SSAKE assembly pipeline on bacterial sequence data. It will need ca.4GB RAM
echo ------------------------------------------------------------------------------------ 
echo Downloading trimmed/formatted data for Campylobacter showae on $d ...
echo ------------------------------------------------------------------------------------
wget ftp://ftp.bcgsc.ca/supplementary/SSAKE/CC57C*
echo ------------------------------------------------------------------------------------
echo done. Initiating SSAKE assembly ETA 10-20min depending on system...
echo ------------------------------------------------------------------------------------
time ../SSAKE -f CC57C_paired.fa -p 1 -g CC57C_unpaired.fa -m 20 -w 5 -b CC57C
echo ------------------------------------------------------------------------------------
echo done. Converting scaffold .csv into fasta file...
echo ------------------------------------------------------------------------------------
../tools/makeFastaFileFromScaffolds.pl CC57C.scaffolds
echo ------------------------------------------------------------------------------------
echo done. Computing stats from CC57C.contigs 
echo ------------------------------------------------------------------------------------
../tools/getStats.pl CC57C.contigs > CC57C.contigs.stats
echo ------------------------------------------------------------------------------------
echo done. Computing stats from CC57C.scaffolds.fa
echo ------------------------------------------------------------------------------------
../tools/getStats.pl CC57C.scaffolds.fa > CC57C.scaffolds.stats
echo assembly pipeline complete. Results are under CC57C.
