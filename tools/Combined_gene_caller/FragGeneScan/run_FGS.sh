#!/bin/bash

while getopts i:o:s: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
		o) OUTNAME=${OPTARG};;
		s) SEQ_TYPE=${OPTARG};;

	esac
done

RUN_DIR=$(dirname $(which FragGeneScan))

${RUN_DIR}/FragGeneScan \
  -p 4 \
  -t illumina_5 \
  -o ${OUTNAME}  \
  -s ${INPUT} \
  -w ${SEQ_TYPE}
echo $?