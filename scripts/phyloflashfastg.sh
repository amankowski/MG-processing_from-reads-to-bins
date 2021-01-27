#!/bin/bash

while getopts L:c:f:p: option
do
case "${option}"
in
L) LIB=${OPTARG};;
c) CONTIGS=${OPTARG};;
f) FASTG=${OPTARG};;
p) PATHS=${OPTARG};;
esac
done


cd /scratch/${USER}/tmp.${JOB_ID}/binning/phyloflash

phyloFlash_fastgFishing.pl --fasta ${CONTIGS} --fastg ${FASTG} --paths ${PATHS} --assembler spades --out ${LIB} --CPUs 24 --clusteronly --outfasta
awk '{print $2"\tphyloflash."$1}' ${LIB}.nodes_to_cluster.tab > /scratch/${USER}/tmp.${JOB_ID}/binning/dastool/data/phyloflash.scaffolds2bin.tsv
for f in *fasta; do mv $f ${f/bin/phyloflash.bin}; done

cd /scratch/${USER}/tmp.${JOB_ID}/binning
