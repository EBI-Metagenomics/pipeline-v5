#!/bin/bash
while getopts f:n: option; do
	case "${option}" in
		f) FASTA=${OPTARG};;
		n) NAME=${OPTARG};;
	esac
done

mkdir -p index && \
cat ${FASTA} | bgzip -c > $NAME.bgz && \
samtools faidx $NAME.bgz
# && mv $NAME.bgz.fai index/ && mv $NAME.bgz index/
