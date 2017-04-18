#!/usr/bin/bash
# USAGE: ./runSSAKE.sh <read1.fq> <read2.fq> <library fragment length(bp)> <basename>
d=`date`
if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ] || [ "$4" == "" ]; then
   echo USAGE: ./runSSAKE.sh read1.fq read2.fq libraryFragmentLength basename
   exit
fi
echo Running: ./runSSAKE.sh $1 $2 $3 $4
echo =================================================================================== 
echo $d : Running SSAKE assembly pipeline on reads file:
echo $1
echo $2 
echo target fragment length = $3 bp
echo basename for assembly : $4
d=`date`
echo -----------------------------------------------------------------------------------
echo $d : Trimming low quality bases, be patient...
echo -----------------------------------------------------------------------------------
echo $1 > filesToTrim.fof
echo $2 >> filesToTrim.fof
../tools/TQSfastq.pl -f filesToTrim.fof -q 20 -n 70 -e 33 
cat $1c70q20e33.fa |perl -ne 'if(/^(\>\@\S+)/){print "$1b\n";}else{print;}' > read1.trimmed.fa
cat $2c70q20e33.fa |perl -ne 'if(/^(\>\@\S+)/){print "$1a\n";}else{print;}' > read2.trimmed.fa
d=`date`
echo -----------------------------------------------------------------------------------
echo $d : Formatting fasta input for SSAKE...
echo -----------------------------------------------------------------------------------
../tools/makePairedOutput2UNEQUALfiles.pl read1.trimmed.fa read2.trimmed.fa $3
d=`date`
echo -----------------------------------------------------------------------------------
echo $d : Initiating SSAKE...
echo -----------------------------------------------------------------------------------
/usr/bin/time -v -o $4.time ../SSAKE -f paired.fa -p 1 -g unpaired.fa -m 20 -w 5 -b $4
d=`date`
echo -----------------------------------------------------------------------------------
echo $d : Converting scaffold .csv into fasta file...
echo -----------------------------------------------------------------------------------
../tools/makeFastaFileFromScaffolds.pl $4.scaffolds
d=`date`
echo -----------------------------------------------------------------------------------
echo $d : Computing stats 
echo -----------------------------------------------------------------------------------
../tools/getStats.pl $4.contigs > $4.contigs.stats
d=`date`
echo -----------------------------------------------------------------------------------
echo $d : Computing stats from $4.scaffolds.fa
echo -----------------------------------------------------------------------------------
../tools/getStats.pl $4.scaffolds.fa > $4.scaffolds.stats
d=`date`
echo -----------------------------------------------------------------------------------
echo $d : assembly pipeline complete. Results are under $4.
