d=`date`
echo ----------------------------------------------------------------------------------- 
echo Running SSAKE assembly pipeline on bacterial sequence data.
echo ------------------------------------------------------------------------------------ 
echo Downloading trimmed/formatted data for Campylobacter showae CC57C on $d ...
echo ------------------------------------------------------------------------------------
rm -rf CC57C_paired.fa
rm -rf CC57C_unpaired.fa
wget http://www.bcgsc.ca/downloads/supplementary/SSAKE/CC57C_paired.fa
wget http://www.bcgsc.ca/downloads/supplementary/SSAKE/CC57C_unpaired.fa
echo ------------------------------------------------------------------------------------
echo done. Initiating SSAKE assembly ETA 10-20min depending on system...
echo ------------------------------------------------------------------------------------
time ../SSAKE -f CC57C_paired.fa -p 1 -g CC57C_unpaired.fa -m 20 -w 5 -b CC57C
echo ------------------------------------------------------------------------------------
echo done. Computing stats from contigs 
echo ------------------------------------------------------------------------------------
../tools/getStats.pl CC57C_contigs.fa 500 > CC57C_contigs_stats.txt
echo ------------------------------------------------------------------------------------
echo done. Computing stats from scaffolds
echo ------------------------------------------------------------------------------------
../tools/getStats.pl CC57C_scaffolds.fa 500 > CC57C_scaffolds_stats.txt
echo assembly pipeline complete. Results are under CC57C.
