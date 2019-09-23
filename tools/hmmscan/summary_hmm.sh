#!/bin/bash

while getopts i: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
	esac
done

export OUTPUT='summary.hmmscan'

sed 's/\t/ /23g' ${INPUT} | cut -f1,23 | sort | uniq -c > ${OUTPUT}