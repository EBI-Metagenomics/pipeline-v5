#!/bin/bash
while getopts f: option; do
	case "${option}" in
		f) FASTA=${OPTARG};;
	esac
done

mkdir -p index && \
cat ${FASTA} | bgzip -c > $FASTA.bgz && \
samtools faidx $FASTA.bgz && mv $FASTA.bgz.fai index/ && \
mv $FASTA.bgz index/
