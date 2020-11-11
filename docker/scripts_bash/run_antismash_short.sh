#!/bin/bash

set -e

while getopts i:o: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
		o) OUTFOLDER=${OPTARG};;
		*) echo "Invalid argument"; exit 1;;
	esac
done

echo "run antismash"
if [ -z "$CONDA_ENV" ]; then
    echo "conda enviroment is empty = using docker"
else
	# shellcheck source=/dev/null
    source "${CONDA_ENV}" antismash
fi

if [ -n "${ANTISMASH_ENV_ACTIVATE}" ];
then
	# ENV in PATH
	echo "Activating env in ${ANTISMASH_ENV_ACTIVATE}"
	# shellcheck source=/dev/null
	source "${ANTISMASH_ENV_ACTIVATE}"
fi

antismash --genefinding prodigal-m --smcogs --asf --disable-svg --knownclusterblast --outputfolder "${OUTFOLDER}" "${INPUT}"
