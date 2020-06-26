#!/bin/bash

# Esl index wrapper because Toil doesn't see output files

while getopts f: option; do
	case "${option}" in
		f) FASTA=${OPTARG};;
	esac
done


esl-sfetch --index ${FASTA}

sleep 60

mkdir folder
mv ${FASTA}* folder