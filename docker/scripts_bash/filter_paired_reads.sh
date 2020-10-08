#!/bin/bash

set -e

while getopts :f:r:l: option; do
	case "${option}" in
		f) FORWARD=${OPTARG};;
		r) REVERSE=${OPTARG};;
		l) LEN=${OPTARG};;
	esac
done

gunzip -c ${FORWARD} > forward.fastq
gunzip -c ${REVERSE} > reverse.fastq

seqtk comp forward.fastq | awk -v l="${LEN}" '{ if ($2 >= l) { print} }' | cut -f1 | sort > selected_1
seqtk comp reverse.fastq | awk -v l="${LEN}" '{ if ($2 >= l) { print} }' | cut -f1 | sort > selected_2

comm -12 selected_1 selected_2 > common

seqtk subseq forward.fastq common > forward_filt.fastq
seqtk subseq reverse.fastq common > reverse_filt.fastq