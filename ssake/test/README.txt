January 2018
------------
TEST DATA / SSAKE ASSEMBLIES


A) Testing the distribution with very short reads:

../SSAKE -f Herpesvirus_3.60kb.reads.fa -m 16 -o 2 -w 5 -c 1 -b HStestInstall 


B) Testing the targeted assembly using a seed/target sequence:

../SSAKE -f Herpesvirus_3.60kb.reads.fa -m 16 -o 2 -w 5 -b seedtest -c 1 -s Herpesvirus_3.60kb.seed.fa -u 1 -i 0 -j 20


C) Testing SSAKE on real (experimental) MiSeq sequence data

1) Ebola (Zaire ebolavirus isolate Ebola)

./MiSeqEbolaAssemblyPIPELINE.sh
(read download,trimming,formatting,assembly)


2) Campylobacter showae - CRC tumor isolate / Illumina MiSeq data

./MiSeqCampylobacterAssemblyPIPELINE.sh
(read download,trimming,formatting,assembly)

or 

./MiSeqCampylobacterAssembly.sh

(just the assembly)


3) Escherichia coli / 2014 Illumina MiSeq data

./MiSeqEcoliAssembly250XPE300.sh

(just the assembly)

This is illumina MiSeq base space data (one tenth of 2500-fold coverage run)
sequence ~ 250X, 550bp fragments PE300

*compare your assembly to:
coliMiSeq300m80.contigs.stats1
coliMiSeq300m80.scaffolds.stats1


4) Fusobacterium nucleatum - CRC tumor isolate / Illumina HiSeq 2000 data

./HiSeqFusobacteriumAssembly.sh

(read download, assembly)


5) De Novo Targeted assembly of a TMPRSS2:ERG fusion using a prostate adenocarcinoma RNA-seq dataset

./runSSAKEtargeted.sh

(read download,trimming,formatting,assembly)


6) C. elegans linked-read assembly

./CelegansLinkedReadsAssembly.sh

(read download, assembly)
