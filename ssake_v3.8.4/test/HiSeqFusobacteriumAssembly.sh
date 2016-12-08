d=`date`
echo ----------------------------------------------------------------------------------- 
echo Running SSAKE assembly pipeline on bacterial sequence data. It will need ca.4GB RAM
echo ------------------------------------------------------------------------------------ 
echo Downloading trimmed/formatted data for Fusobacterium nucleatum CC53 on $d ...
echo ------------------------------------------------------------------------------------
rm -rf CC53_2million.fa
wget ftp://ftp.bcgsc.ca/supplementary/SSAKE/CC53_2million.fa
echo ------------------------------------------------------------------------------------
echo done. Initiating SSAKE assembly ETA 10-20min depending on system...
echo ------------------------------------------------------------------------------------
time ../SSAKE -f CC53_2million.fa -p 1 -m 20 -w 5 -b fusoCC53-1
echo ------------------------------------------------------------------------------------
echo done. Converting scaffold .csv into fasta file...
echo ------------------------------------------------------------------------------------
../tools/makeFastaFileFromScaffolds.pl fusoCC53-1.scaffolds
echo ------------------------------------------------------------------------------------
echo done. Computing stats from fusoCC53-1.contigs 
echo ------------------------------------------------------------------------------------
../tools/getStats.pl fusoCC53-1.contigs 500 > fusoCC53-1.contigs.stats
echo ------------------------------------------------------------------------------------
echo done. Computing stats from fusoCC53-1.scaffolds.fa
echo ------------------------------------------------------------------------------------
../tools/getStats.pl fusoCC53-1.scaffolds.fa 500 > fusoCC53-1.scaffolds.stats
echo assembly pipeline complete. Results are under fusoCC53-1.
