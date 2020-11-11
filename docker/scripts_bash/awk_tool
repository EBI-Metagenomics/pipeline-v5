#!/bin/bash
while getopts i:n: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
		n) NAME=${OPTARG};;
	esac
done

awk '{print $1"-"$3"/q"$8"-"$9" "$8" "$9" "$1}' ${INPUT} > ${NAME}".matched_seqs_with_coords"