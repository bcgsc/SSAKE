d=`date`
echo ----------------------------------------------------------------------------------- 
echo Running SSAKE assembly pipeline on bacterial sequence data.
echo ------------------------------------------------------------------------------------ 
echo Downloading trimmed/formatted data for Fusobacterium nucleatum CC53 on $d ...
echo ------------------------------------------------------------------------------------
rm -rf CC53_2million.fa
wget http://www.bcgsc.ca/downloads/supplementary/SSAKE/CC53_2million.fa
echo ------------------------------------------------------------------------------------
echo done. Initiating SSAKE assembly ETA 10-20min depending on system...
echo ------------------------------------------------------------------------------------
time ../SSAKE -f CC53_2million.fa -p 1 -m 20 -w 5 -b fusoCC53
echo ------------------------------------------------------------------------------------
echo done. Computing stats from contigs
echo ------------------------------------------------------------------------------------
../tools/getStats.pl fusoCC53_contigs.fa 500 > fusoCC53_contigs_stats.txt
echo done. Computing stats from scaffolds 
echo ------------------------------------------------------------------------------------
../tools/getStats.pl fusoCC53_scaffolds.fa 500 > fusoCC53_scaffolds_stats.txt
echo assembly pipeline complete. Results are under fusoCC53.
