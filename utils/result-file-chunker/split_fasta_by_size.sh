#!/bin/bash
while getopts i:n: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
		n) NUMBER=${OPTARG};;
	esac
done

if [[ -s ${INPUT} ]]
then
    cp ${INPUT} copy.fasta
    gt splitfasta -targetsize ${NUMBER} copy.fasta
    rm copy.fasta
else
    touch copy.fasta
fi