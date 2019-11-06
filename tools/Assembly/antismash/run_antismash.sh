#!/bin/bash

while getopts i:o: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
		o) OUTFOLDER=${OPTARG};;
	esac
done

source ${CONDA_ENV} antismash && \
antismash \
  -v \
  --smcogs  \
  --transatpks_da  \
  --borderpredict  \
  --asf  \
  --inclusive  \
  --outputfolder ${OUTFOLDER} \
  ${INPUT}