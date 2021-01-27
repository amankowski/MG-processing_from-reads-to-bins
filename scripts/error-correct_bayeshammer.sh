#!/bin/bash

while getopts T: option
do
case "${option}"
in
T) RT=${OPTARG};;
esac
done

/home/mankowski/tools/SPAdes-3.12.0-Linux/bin/spades.py --12 ${RT} -o bayeshammer --only-error-correction --threads 64 -m 500
