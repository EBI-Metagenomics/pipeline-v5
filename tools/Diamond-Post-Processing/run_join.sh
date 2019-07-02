#!/bin/bash
while getopts i:d: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
		d) DB=${OPTARG};;
	esac 
done
join -t $'\t' -1 2 -2 1 ${INPUT} ${DB}
