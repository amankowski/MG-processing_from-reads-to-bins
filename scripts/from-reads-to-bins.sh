#!/bin/bash
#$ -cwd
#$ -j y
#$ -pe smp 64
#$ -R y
#$ -q main.q@@himem
#$ -S /bin/bash

TRIM='false'
QC='false'
EC='false'
BIN='false'

while getopts 'L:A:C:I:F:R:r:c:f:p:k:o:B:tqeb' option
do
case "${option}"
in
L) LIB=${OPTARG};;          # sample/library name, used as prefix/for output directories
A) ADAPTERS=${OPTARG};;     # file with illumina adapters that should be trimmed
C) COIDB=${OPTARG};;        # custome COIFlash DB
I) INT=${OPTARG};;          # interleaved read file, specify if your reads are present in this format
F) FW=${OPTARG};;           # forward read file, specify if your reads are present in none-interleaved format
R) RV=${OPTARG};;           # reverse read file, specify if your reads are present in none-interleaved format
r) READLENGTH=${OPTARG};;   # readlength, 150 or 250 bp
c) CONTIGS=${OPTARG};;      # assembly contigs file, specify if your spades assembly is already done
f) FASTG=${OPTARG};;        # assembly fastg file, specify if your spades assembly is already done
p) PATHS=${OPTARG};;        # assembly paths file, specify if your spades assembly is already done
k) KMER=${OPTARG};;         # kmers you want to use fpr your spades assembly
o) OUTDIR=${OPTARG};;       # directory where processed data will be moved to (subdirectory named $LIB will be created)
B) BINNING=${OPTARG};;      # directory where binning output will be moved to (subdirectory named $LIB will be created)
t) TRIM='true';;            # specify if you want trimming/filtering with bbduk
q) QC='true';;              # specify if you want quality control with fastqc, coiflash and phyloflash
e) EC='true';;              # specify if you want error correction with bayeshammer
b) BIN='true';;             # specify if you want to do binning (in case no contigs/graph/paths files are provide, spades assembly will also be performed)
esac
done

SCRIPTS=/opt/extern/bremen/symbiosis/mankowski/workflows/basic_metagenomics/scripts
SPADES_OUT=$(echo spades_${KMER}|sed 's/,/-/g')

echo "###########################################################################################"
echo "Start initial data analysis pipeline..."
echo "Library: ${LIB}"
echo "job ID: $JOB_ID"
date
hostname
echo "###########################################################################################"

mkdir /scratch/${USER}/tmp.${JOB_ID} -p
cd /scratch/${USER}/tmp.${JOB_ID}

if [ ! -z "${INT}" ]; then
  cp ${INT} /scratch/${USER}/tmp.${JOB_ID}
  RI=$(echo ${INT}|awk -F"/" '{print $NF}')
  if ${TRIM}; then
    ${SCRIPTS}/trim-and-filter_bbduk.sh -L ${LIB} -A ${ADAPTERS} -I ${RI} -r ${READLENGTH}
    RT=${LIB}-trimlr-filtered.fq.gz
  else
    RT=${RI}
  fi
  if ${QC}; then
    ${SCRIPTS}/qc_fastqc-coif-pf.sh -S ${SCRIPTS} -L ${LIB} -C ${COIDB} -I ${RI} -T ${RT} -r ${READLENGTH}
  fi
elif [ ! -z "${FW}" ] && [ ! -z "${RV}" ]; then
  cp ${FW} ${RV} /scratch/${USER}/tmp.${JOB_ID}
  R1=$(echo ${FW}|awk -F"/" '{print $NF}')
  R2=$(echo ${RV}|awk -F"/" '{print $NF}')
  if ${TRIM}; then
    ${SCRIPTS}/trim-and-filter_bbduk.sh -L ${LIB} -A ${ADAPTERS} -F ${R1} -R ${R2} -r ${READLENGTH}
  else
    reformat.sh in=${R1} in2=${R2} out=${LIB}-trimlr-filtered.fq.gz
  fi
  RT=${LIB}-trimlr-filtered.fq.gz
  if ${QC}; then
    ${SCRIPTS}/qc_fastqc-coif-pf.sh -S ${SCRIPTS} -L ${LIB} -C ${COIDB} -T ${RT} -r ${READLENGTH}
  fi
fi

if ${EC}; then
  ${SCRIPTS}/error-correct_bayeshammer.sh -T ${RT}
  R1=/scratch/${USER}/tmp.${JOB_ID}/bayeshammer/corrected/${RT%%.f[^.].gz}_1.00.0_0.cor.fastq.gz
  R2=/scratch/${USER}/tmp.${JOB_ID}/bayeshammer/corrected/${RT%%.f[^.].gz}_2.00.0_0.cor.fastq.gz
  reformat.sh in1=${R1} in2=${R2} out=${R1%%_1.00.0_0.cor.fastq.gz}.corrected.fq.gz
  RT=${R1%%_1.00.0_0.cor.fastq.gz}.corrected.fq.gz
else
  reformat.sh in=${RT} out1=${RT%%.f[^.].gz}_1.fq.gz out2=${RT%%.f[^.].gz}_2.fq.gz
  R1=/scratch/${USER}/tmp.${JOB_ID}/${RT%%.f[^.].gz}_1.fq.gz
  R2=/scratch/${USER}/tmp.${JOB_ID}/${RT%%.f[^.].gz}_2.fq.gz
  RT=/scratch/${USER}/tmp.${JOB_ID}/${LIB}-trimlr-filtered.fq.gz
fi

if ${BIN}; then
  if [ -z ${CONTIGS} ] && [ -z "${FASTG}" ] && [ -z "${PATHS}" ]; then
    ${SCRIPTS}/assembly_spades.sh -F ${R1} -R ${R2} -k ${KMER}
    CONTIGS=/scratch/${USER}/tmp.${JOB_ID}/${SPADES_OUT}/contigs.fasta
    FASTG=/scratch/${USER}/tmp.${JOB_ID}/${SPADES_OUT}/assembly_graph.fastg
    PATHS=/scratch/${USER}/tmp.${JOB_ID}/${SPADES_OUT}/contigs.paths
  else
    cp ${CONTIGS} ${FASTG} ${PATHS} /scratch/${USER}/tmp.${JOB_ID}/
    CONTIGS_F=$(echo ${CONTIGS}|awk -F"/" '{print $NF}')
    CONTIGS=/scratch/${USER}/tmp.${JOB_ID}/${CONTIGS_F}
    FASTG_F=$(echo ${FASTG}|awk -F"/" '{print $NF}')
    FASTG=/scratch/${USER}/tmp.${JOB_ID}/${FASTG_F}
    PATHS_F=$(echo ${PATHS}|awk -F"/" '{print $NF}')
    PATHS=/scratch/${USER}/tmp.${JOB_ID}/${PATHS_F}
  fi
  ${SCRIPTS}/binning.sh -S ${SCRIPTS} -L ${LIB} -F ${R1} -R ${R2} -T ${RT} -c ${CONTIGS} -f ${FASTG} -p ${PATHS}
fi

echo "###########################################################################################"
echo "Finished initial data analysis pipeline, copy results..."
echo "Library: ${LIB}"
echo "job ID: $JOB_ID"
date
hostname
echo "###########################################################################################"

mkdir ${OUTDIR}/${LIB} ${BINNING}/${LIB}
rsync -a /scratch/${USER}/tmp.${JOB_ID}/fastqc /scratch/${USER}/tmp.${JOB_ID}/coiflash /scratch/${USER}/tmp.${JOB_ID}/phyloflash /scratch/${USER}/tmp.${JOB_ID}/bayeshammer /scratch/${USER}/tmp.${JOB_ID}/${SPADES_OUT}  ${OUTDIR}/${LIB}
if [ "$?" -eq "0" ]; then
  echo "Successfully copied processed data"
  date
else
  echo "Error while rsyncing processed data"
fi
rsync -a /scratch/${USER}/tmp.${JOB_ID}/binning/ ${BINNING}/${LIB}
if [ "$?" -eq "0" ]; then
  echo "Successfully copied bins, linking them..."
  date
  cd /scratch/${USER}/tmp.${JOB_ID}
else
  echo "Error while rsyncing bins"
fi
