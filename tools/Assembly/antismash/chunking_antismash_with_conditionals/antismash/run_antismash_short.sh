#!/bin/bash

while getopts i:o:g:n:f: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
		o) OUTFOLDER=${OPTARG};;
	esac
done

echo "run antismash"
source ${CONDA_ENV} antismash && \
antismash -v --smcogs --asf --disable-svg --knownclusterblast --subclusterblast --outputfolder ${OUTFOLDER} ${INPUT}