#!/bin/bash

while getopts L:C:T:r: option
do
case "${option}"
in
L) LIB=${OPTARG};;
C) COIDB=${OPTARG};;
T) RT=${OPTARG};;
r) READLENGTH=${OPTARG};;
esac
done

mkdir coiflash
cd coiflash
/opt/extern/bremen/symbiosis/COIFlash/COIFlash.pl -lib ${LIB} -read1 /scratch/${USER}/tmp.$JOB_ID/${RT} -interleaved -readlength ${READLENGTH} -CPUs 12 -dbhome ${COIDB} -skip_emirge

cd /scratch/${USER}/tmp.$JOB_ID
