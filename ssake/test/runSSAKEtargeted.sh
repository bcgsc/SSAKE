echo Running: runSSAKEtargeted.sh
echo THE FOLLOWING WILL RUN SSAKE IN *TARGETED* ASSEMBLY MODE
echo RECONSTRUCTING A TRANSCRIPT FUSION SEQUENCE FROM targets.fa DE NOVO using a PROSTATE ADENOCARCINOMA RNAseq DATASET
echo Downloading NGS reads
wget ftp://ftp.bcgsc.ca/supplementary/SSAKE/SRR066437.fastq.bz2
echo Decompressing
bunzip2 SRR066437.fastq.bz2
echo Trimming reads
echo SRR066437.fastq > SRR066437.fof
../tools/TQSfastq.pl -f SRR066437.fof -q 20 -n 20 -e 33
echo Running SSAKE in targeted assembly mode, not restricted to target sequence space -u 0 
../SSAKE -s fusion-targets.fa -f SRR066437.fastqc20q20e33.fa -m 16 -c 1 -b targetedUnrestricted -w 1 -u 0 -i 0
echo Running SSAKE in targeted assembly mode, restricted to target sequence space -u 1 
../SSAKE -s fusion-targets.fa -f SRR066437.fastqc20q20e33.fa -m 16 -c 1 -b targetedRestricted -w 1 -u 1 -i 0
echo Consider running TASR for additional targeted assembly features, such as de novo assembly directly from bam files
echo http://www.bcgsc.ca/platform/bioinfo/software/tasr
