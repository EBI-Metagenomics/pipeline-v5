#!/bin/bash
while getopts f: option; do
	case "${option}" in
		f) FASTA=${OPTARG};;
	esac
done

mkdir -p index && samtools faidx $FASTA && mv $FASTA.fai index/