#!/bin/bash

while getopts L:c: option
do
case "${option}"
in
L) LIB=${OPTARG};;
c) CONTIGS=${OPTARG};;
esac
done

echo "#############################"
echo "Start dastool binning"
date

cd /scratch/${USER}/tmp.${JOB_ID}/binning/dastool/data
empty=$(ls -l|awk '$5 == 0 {print $NF}')
rm $empty
files=$((echo '' && ls)|tr '\n' ',data/'|sed 's/,$//g'|sed 's#,#,data/#g'|sed 's/^,//g')
cd /scratch/${USER}/tmp.${JOB_ID}/binning/dastool
/home/mankowski/tools/DAS_Tool-master/DAS_Tool -i $files -c ${CONTIGS} -o results/${LIB} --write_bins 1 -t 64

if [ -d /scratch/${USER}/tmp.${JOB_ID}/binning/dastool/results/${LIB}_DASTool_bins ]; then
  cd /scratch/${USER}/tmp.${JOB_ID}/binning/dastool/results/${LIB}_DASTool_bins
  for f in *fa; do mv $f ${LIB}.dastool.${f}; done
  for f in *fa; do mv $f ${f/.fa/.fasta}; done
fi

cd /scratch/${USER}/tmp.${JOB_ID}/binning
