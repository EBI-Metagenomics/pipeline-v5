#!/bin/bash

while getopts f: option; do
	case "${option}" in
		f) INPUT_FILE=${OPTARG};;
	esac
done

var="$(cat ${INPUT_FILE} | wc -l)"
echo $((${var} / 4)) > data.txt
