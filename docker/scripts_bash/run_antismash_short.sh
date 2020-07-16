#!/bin/bash

while getopts i:o:g:n:f: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
		o) OUTFOLDER=${OPTARG};;
	esac
done

echo "run antismash"
if [ -z "$CONDA_ENV" ]; then
    echo "conda enviroment is empty = using docker"
else
    source ${CONDA_ENV} antismash
antismash --smcogs --asf --disable-svg --knownclusterblast --outputfolder ${OUTFOLDER} ${INPUT}  # --subclusterblast -v