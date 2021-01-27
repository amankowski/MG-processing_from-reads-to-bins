#!/bin/bash

while getopts L:B:a: option
do
case "${option}"
in
L) LIB=${OPTARG};;
B) BINNING=${OPTARG};;
a) ALLBINS=${OPTARG};;
esac
done

cd ${BINNING}/${LIB}/phyloflash
for f in $(ls ${LIB}*fasta); do ln -s ${BINNING}/${LIB}/phyloflash/${f} ${ALLBINS}; done

cd ${BINNING}/${LIB}/maxbin
for f in $(ls ${LIB}*fasta); do ln -s ${BINNING}/${LIB}/maxbin/${f} ${ALLBINS}; done

cd ${BINNING}/${LIB}/metabat
for f in $(ls ${LIB}*fasta); do ln -s ${BINNING}/${LIB}/metabat/${f} ${ALLBINS}; done

cd ${BINNING}/${LIB}/autometa
for f in $(ls ${LIB}*autometa*fasta); do ln -s ${BINNING}/${LIB}/autometa/${f} ${ALLBINS}; done

if [ -d ${BINNING}/${LIB}/dastool/results/${LIB}_DASTool_bins ]; then
  cd ${BINNING}/${LIB}/dastool/results/${LIB}_DASTool_bins
  if [[ $(ls -l|grep fasta|wc -l) -ge 1 ]]; then
     for f in ${LIB}*fasta; do ln -s ${BINNING}/${LIB}/dastool/results/${LIB}_DASTool_bins/${f} ${ALLBINS}; done
  fi
fi
