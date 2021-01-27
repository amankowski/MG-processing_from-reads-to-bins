#!/bin/bash

while getopts L:I:T: option
do
case "${option}"
in
L) LIB=${OPTARG};;
I) RI=${OPTARG};;
T) RT=${OPTARG};;
esac
done

mkdir fastqc

if [ ! -z "${RI}" ]; then
  if [ ${RI} == ${RT} ]; then
    /opt/share/software/bin/fastqc --threads 64 --outdir /scratch/${USER}/tmp.${JOB_ID}/fastqc /scratch/${USER}/tmp.${JOB_ID}/${RT}
  else
    /opt/share/software/bin/fastqc --threads 64 --outdir /scratch/${USER}/tmp.${JOB_ID}/fastqc /scratch/${USER}/tmp.${JOB_ID}/${RT}
    /opt/share/software/bin/fastqc --threads 64 --outdir /scratch/${USER}/tmp.${JOB_ID}/fastqc /scratch/${USER}/tmp.${JOB_ID}/${RI}
  fi
else
  /opt/share/software/bin/fastqc --threads 64 --outdir /scratch/${USER}/tmp.${JOB_ID}/fastqc /scratch/${USER}/tmp.${JOB_ID}/*.fastq.gz
  /opt/share/software/bin/fastqc --threads 64 --outdir /scratch/${USER}/tmp.${JOB_ID}/fastqc /scratch/${USER}/tmp.${JOB_ID}/${RT}
  rm *fastq.gz
fi
