#!/bin/bash

while getopts L:T:r: option
do
case "${option}"
in
L) LIB=${OPTARG};;
T) RT=${OPTARG};;
r) READLENGTH=${OPTARG};;
esac
done

mkdir phyloflash
cd phyloflash

/opt/extern/bremen/symbiosis/tools_HGV/phyloFlash/phyloFlash.pl -lib ${LIB} -read1 /scratch/${USER}/tmp.$JOB_ID/${RT} -interleaved -readlength ${READLENGTH} -CPUs 64 -everything

cd /scratch/${USER}/tmp.${JOB_ID}
