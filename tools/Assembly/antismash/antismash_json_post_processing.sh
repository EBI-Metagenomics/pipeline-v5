#!/bin/bash

while getopts i: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
	esac
done

echo ";var fs = require('fs'); fs.writeFileSync('geneclusters.json', JSON.stringify(geneclusters));" >> ${INPUT} && \
node ${INPUT}

