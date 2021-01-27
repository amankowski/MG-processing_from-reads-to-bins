#!/bin/bash

while getopts L:F:R:c: option
do
case "${option}"
in
L) LIB=${OPTARG};;
F) FW=${OPTARG};;
R) RV=${OPTARG};;
c) CONTIGS=${OPTARG};;
esac
done

echo "#############################"
echo "Start autometa binning"
date

cd /scratch/${USER}/tmp.${JOB_ID}/binning/autometa

calculate_read_coverage.py --assembly ${CONTIGS} --processors 64 --forward_reads ${FW} --reverse_reads ${RV}
run_autometa.py --assembly ${CONTIGS} --processors 64 --length_cutoff 1500 -db /opt/share/blastdb/Autometa-1.0/databases --maketaxtable --ML_recruitment
cluster_process.py --bin_table ML_recruitment_output.tab --column ML_expanded_clustering --fasta Bacteria.fasta --do_taxonomy --db_dir /opt/share/blastdb/Autometa-1.0/databases --output_dir cluster_process_output

tail -n +2 recursive_dbscan_output.tab|grep -v unclustered|awk '{print $1"\t"$NF}'|sed -r 's/DBSCAN_round([0-9]*)_/autometa.bin\1_/g'|sort -k2 >/scratch/${USER}/tmp.${JOB_ID}/binning/dastool/data/autometa.scaffolds2bin.tsv
mv cluster_process_output/*fasta .
for f in cluster_DBSCAN*; do mv "$f" ${f/cluster_DBSCAN_round/${LIB}.autometa.bin}; done

cd /scratch/${USER}/tmp.${JOB_ID}/binning
