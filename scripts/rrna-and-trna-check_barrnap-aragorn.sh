#!/bin/bash

while getopts 's:b:B:A:Q:' option
do
case "${option}"
in
s) SYM=${OPTARG};;
b) BINS=${OPTARG};;
B) BARRNAP=${OPTARG};;
A) ARAGORN=${OPTARG};;
Q) QA=${OPTARG};;
esac
done

mkdir ${BARRNAP}/${SYM}
mkdir ${ARAGORN}/${SYM}
cd ${BINS}/${SYM}

for f in *fasta; do barrnap --threads 12 --outseq ${BARRNAP}/${SYM}/${f%%.fasta}.rrnas.fasta < ${f} > ${BARRNAP}/${SYM}/${f%%.fasta}.gff; done
for f in *fasta; do paste <(echo ${f%%.fasta}) <(aragorn -t -fon ${f} | grep '>' | cut -d' ' -f2 | cut -d'-' -f2 | cut -d '(' -f1 |sort -u |wc -l); done > ${ARAGORN}/${SYM}/trna_check

cd ${BARRNAP}/${SYM}
for f in *gff; do
  if [[ $(tail -n +2 ${f}|awk '{print $9}'|awk -F"=" '{print $2}'|awk -F";" '{print $1}'|sort -u|wc -l) -eq 3 ]]; then
    echo -e "${f%%.gff}\tcomplete" >> rrna_check
  elif [[ $(tail -n +2 ${f}|awk '{print $9}'|awk -F"=" '{print $2}'|awk -F";" '{print $1}'|sort -u|wc -l) -ge 1 ]]; then
    echo -e "${f%%.gff}\tpartly" >> rrna_check
  elif [[ $(tail -n +2 ${f}|awk '{print $9}'|awk -F"=" '{print $2}'|awk -F";" '{print $1}'|sort -u|wc -l) -eq 0 ]]; then
    echo -e "${f%%.gff}\tnone" >> rrna_check
  fi
done

cd ${QA}
join -j 1 -o 1.1,1.2,1.3,1.4,1.5,2.2 <(tail -n +2 ${SYM}_qa-out_2_mod|sort -k1) <(sort -k1 ${BARRNAP}/${SYM}/rrna_check) > tmp && mv tmp ${SYM}_qa-out_2_mod
join -j 1 -o 1.1,1.2,1.3,1.4,1.5,1.6,2.2 <(sort -k1 ${SYM}_qa-out_2_mod) <(sort -k1 ${ARAGORN}/${SYM}/trna_check) > tmp && mv tmp ${SYM}_qa-out_2_mod
(echo -e 'Bin_ID\tCompleteness\tContamination\tStrain_heterogeneity\tGenome_size_(bp)\trRNAs\ttRNAs' && cat ${SYM}_qa-out_2_mod) > tmp && mv tmp ${SYM}_qa-out_2_mod
