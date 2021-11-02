#!/bin/bash

set -e

while getopts f:n: option; do
	case "${option}" in
	f) FASTA=${OPTARG} ;;
	n) NAME=${OPTARG} ;;
	*)
		echo "Invalid option: ${option}"
		exit 1
		;;
	esac
done

mkdir -p index

cat "${FASTA}" | bgzip -c >"${NAME}.bgz"

samtools faidx "${NAME}.bgz"
