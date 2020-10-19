#!/bin/bash
while getopts i:n: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
		n) NUMBER=${OPTARG};;
	esac
done

cp ${INPUT} copy.fasta

gt splitfasta -targetsize ${NUMBER} copy.fasta