#!/bin/bash

while getopts i:o:g:n:f: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
		o) OUTFOLDER=${OPTARG};;
	esac
done

echo "run antismash"
source ${CONDA_ENV} antismash && \
antismash --genefinding prodigal-m --smcogs --asf --disable-svg --knownclusterblast --outputfolder ${OUTFOLDER} ${INPUT}  # --subclusterblast -v