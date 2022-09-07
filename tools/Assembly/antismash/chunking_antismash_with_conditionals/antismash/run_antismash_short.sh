#!/bin/bash

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

if [ $? -eq 0 ]; then
	echo "Success"
else
	echo "Creating empty folder"
	rm -rf "${OUTFOLDER}"
	mkdir -p "${OUTFOLDER}" &&
		touch "${OUTFOLDER}"/geneclusters.js "${OUTFOLDER}"/geneclusters.txt "${OUTFOLDER}"/empty.final.embl "${OUTFOLDER}"/empty.final.gbk
fi
