#!/bin/bash

while getopts L:c:F:R: option
do
case "${option}"
in
L) LIB=${OPTARG};;
c) CONTIGS=${OPTARG};;
F) FW=${OPTARG};;
R) RV=${OPTARG};;
esac
done

echo "#############################"
echo "Start metabat binning"
date

cd /scratch/${USER}/tmp.${JOB_ID}/binning/metabat

bbmap.sh  in=${FW} in2=${RV} ref=${CONTIGS} outm=out.bam outputunmapped=f nodisk=t unpigz=t pigz=t threads=64
samtools sort --threads 64 out.bam -o out.sorted.bam
rm out.bam
jgi_summarize_bam_contig_depths --outputDepth depth.txt out.sorted.bam
rm out.sorted.bam
metabat2 -i ${CONTIGS} -a depth.txt -o ./bin -t 64 -m 1500

for f in *fa; do grep '>' $f|sed 's/>//g' > ${f%%.fa}.contigs; done
for f in *contigs; do sed -e "s/$/\tmetabat.${f%%.contigs}/g" $f|sed 's/bin./bin/g'; done > /scratch/${USER}/tmp.${JOB_ID}/binning/dastool/data/metabat.scaffolds2bin.tsv
for f in *fa; do mv $f ${f/bin./${LIB}.metabat.bin}; done
for f in *fa; do mv $f ${f/.fa/.fasta}; done

cd /scratch/${USER}/tmp.${JOB_ID}/binning
