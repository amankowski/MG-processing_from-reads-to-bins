#!/bin/bash

while getopts S:L:C:I:T:r: option
do
case "${option}"
in
S) SCRIPTS=${OPTARG};;
L) LIB=${OPTARG};;
C) COIDB=${OPTARG};;
I) RI=${OPTARG};;
T) RT=${OPTARG};;
r) READLENGTH=${OPTARG};;
esac
done

if [ ! -z "${RI}" ]; then
  ${SCRIPTS}/fastqc.sh  -L ${LIB} -T ${RT} -I ${RI}
else
  ${SCRIPTS}/fastqc.sh -L ${LIB} -T ${RT}
fi

${SCRIPTS}/coiflash.sh -L ${LIB} -C ${COIDB} -T ${RT} -r ${READLENGTH}
${SCRIPTS}/phyloflash.sh -L ${LIB} -T ${RT} -r ${READLENGTH}
