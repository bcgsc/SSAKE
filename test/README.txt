May 2014
--------

Testing the distribution with very short reads:

../SSAKE -f Herpesvirus_3.60kb.reads.fa -m 16 -o 2 -w 5 -c 1 

Testing the targeted assembly using a seed/target sequence:

../SSAKE -f Herpesvirus_3.60kb.reads.fa -m 16 -o 2 -w 5 -b seedtest -c 1 -s Herpesvirus_3.60kb.seed.fa -i 1 -j 20

Testing SSAKE on real (experimental) MiSeq sequence data for CRC tumor isolate
Campylobacter showae:

./MiSeqCampylobacterAssemblyPIPELINE.sh
(read download,trimming,formatting,assembly)

or 

./MiSeqCampylobacterAssembly.sh

(just the assembly)
