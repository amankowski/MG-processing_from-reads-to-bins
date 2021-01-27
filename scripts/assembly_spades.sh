#!/bin/bash

while getopts F:R:k: option
do
case "${option}"
in
F) FW=${OPTARG};;
R) RV=${OPTARG};;
k) KMER=${OPTARG};;
esac
done

SPADES_OUT=$(echo spades_${KMER}|sed 's/,/-/g')

/home/mankowski/tools/SPAdes-3.12.0-Linux/bin/spades.py -o /scratch/${USER}/tmp.${JOB_ID}/${SPADES_OUT} --meta -1 ${FW} -2 ${RV} -t 64 -m 500 -k ${KMER} --phred-offset 33 --only-assembler
cd /scratch/${USER}/tmp.${JOB_ID}/spades_${KMER}
rm -rf K[0-9]* misc tmp before_rr.fasta dataset.info first_pe_contigs.fasta input_dataset.yaml params.txt
cd /scratch/${USER}/tmp.${JOB_ID}
