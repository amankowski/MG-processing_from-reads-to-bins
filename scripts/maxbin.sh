#!/bin/bash

while getopts L:c:T: option
do
case "${option}"
in
L) LIB=${OPTARG};;
c) CONTIGS=${OPTARG};;
T) RT=${OPTARG};;
esac
done

echo "#############################"
echo "Start maxbin binning"
date

cd /scratch/${USER}/tmp.${JOB_ID}/binning/maxbin

run_MaxBin.pl -contig ${CONTIGS} -reads ${RT} -out ${LIB} -thread 64 -min_contig_length 1500

for f in *fasta; do grep '>' $f|sed 's/>//g' > ${f%%.fasta}.contigs; done
for f in *contigs; do sed -e "s/$/\tmaxbin.${f%%.contigs}/" $f|sed "s/${LIB}.[0]*/bin/g"; done > /scratch/${USER}/tmp.${JOB_ID}/binning/dastool/data/maxbin.scaffolds2bin.tsv
for f in *fasta; do mv $f ${f/${LIB}./${LIB}.maxbin.bin.}; done
for f in *fasta; do mv $f ${f/bin.00/bin}; done

cd /scratch/${USER}/tmp.${JOB_ID}/binning
