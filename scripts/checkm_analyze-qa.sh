#!/bin/bash
#$ -cwd
#$ -j y
#$ -pe smp 64
#$ -R y
#$ -S /bin/bash


while getopts 'L:C:R:A:' option
do
case "${option}"
in
L) LIB=${OPTARG};;          # sample/library name, used as prefix/for output directories
C) CHECKM=${OPTARG};;       # checkm dir
R) REF=${OPTARG};;          # lineage.ms file
A) ALLBINS=${OPTARG};;      # directory where all generated bins will be linked to
esac
done

cd ${CHECKM}
mkdir ${LIB}/bins -p
cp -P ${ALLBINS}/${LIB}.* ${LIB}/bins

cd ${LIB}
checkm analyze ${REF} bins analyze_out -x fasta -t 64
checkm qa ${REF} analyze_out -o 2 -f qa-out_2 --tab_table 
