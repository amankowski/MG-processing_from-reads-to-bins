#!/bin/bash

while getopts L:A:I:F:R:r: option
do
case "${option}"
in
L) LIB=${OPTARG};;
A) ADAPTERS=${OPTARG};;
I) INT=${OPTARG};;
F) FW=${OPTARG};;
R) RV=${OPTARG};;
r) READLENGTH=${OPTARG};;
esac
done

if [ "$READLENGTH" -eq 250 ]; then
  if [ ! -z "${INT}" ]; then
    bbduk.sh in=${INT} ref=${ADAPTERS} out=${LIB}-trimmed-left.fq.gz threads=64 mink=11 minlength=51 ktrim=l hdist=1
  elif [ ! -z "${FW}" ] && [ ! -z "${RV}" ]; then
    bbduk.sh in1=${FW} in2=${RV} ref=${ADAPTERS} out=${LIB}-trimmed-left.fq.gz threads=64 mink=11 minlength=51 ktrim=l hdist=1
  fi
  bbduk.sh in=${LIB}-trimmed-left.fq.gz ref=${ADAPTERS} out=${LIB}-trimlr-filtered.fq.gz threads=64 mink=11 minlength=51 ktrim=r hdist=1 trimq=2 qtrim=rl
else
  if [ ! -z "${INT}" ]; then
    bbduk.sh in=${INT} ref=${ADAPTERS} out=${LIB}-trimmed-left.fq.gz threads=64 mink=11 minlength=36 ktrim=l hdist=1
  elif [ ! -z "${FW}" ] && [ ! -z "${RV}" ]; then
    bbduk.sh in1=${FW} in2=${RV} ref=${ADAPTERS} out=${LIB}-trimmed-left.fq.gz threads=64 mink=11 minlength=36 ktrim=l hdist=1
  fi
  bbduk.sh in=${LIB}-trimmed-left.fq.gz ref=${ADAPTERS} out=${LIB}-trimlr-filtered.fq.gz threads=64 mink=11 minlength=36 ktrim=r hdist=1 trimq=2 qtrim=rl
fi

rm ${LIB}-trimmed-left.fq.gz
