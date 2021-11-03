#!/bin/bash

set -e

while getopts i:o: option; do
	case "${option}" in
	i) INPUT=${OPTARG} ;;
	o) OUTFOLDER=${OPTARG} ;;
	*) echo "Invalid option: ${option}" ;;
	esac
done

echo "Load antismash conda env"

# shellcheck disable=SC1090
source "${CONDA_ENV}" antismash

antismash --genefinding prodigal-m \
	--smcogs \
	--asf \
	--disable-svg \
	--knownclusterblast \
	--outputfolder "${OUTFOLDER}" "${INPUT}"
