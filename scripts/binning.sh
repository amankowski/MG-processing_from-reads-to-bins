#!/bin/bash

while getopts S:L:F:R:T:c:f:p: option
do
case "${option}"
in
S) SCRIPTS=${OPTARG};;
L) LIB=${OPTARG};;
F) FW=${OPTARG};;
R) RV=${OPTARG};;
T) RT=${OPTARG};;
c) CONTIGS=${OPTARG};;
f) FASTG=${OPTARG};;
p) PATHS=${OPTARG};;
esac
done

mkdir binning
cd binning
mkdir phyloflash metabat maxbin autometa dastool
mkdir dastool/data dastool/results

${SCRIPTS}/phyloflashfastg.sh -L ${LIB} -c ${CONTIGS} -f ${FASTG} -p ${PATHS}
${SCRIPTS}/metabat.sh -L ${LIB} -F ${FW} -R ${RV} -c ${CONTIGS}
${SCRIPTS}/maxbin.sh -L ${LIB} -T ${RT} -c ${CONTIGS}
${SCRIPTS}/autometa.sh -L ${LIB} -F ${FW} -R ${RV} -c ${CONTIGS}
${SCRIPTS}/dastool.sh -L ${LIB} -c ${CONTIGS}

cd /scratch/${USER}/tmp.${JOB_ID}
