#!/bin/bash

while getopts i: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
	esac
done

export OUTPUT_PARSING=parsing_table
export OUTPUT_UNION=union_ko_contigs.txt
export OUTDIR=pathways
mkdir ${OUTDIR}
export OUTPUT=${OUTDIR}/result

echo "parsing hmmscan" && \
python3 /tools/parsing_hmmscan.py -i ${INPUT} -o ${OUTPUT_PARSING} && \
echo "union" && \
python3 /tools/union_by_contigs.py -i ${OUTPUT_PARSING} && \
echo "pathways" && \
python3 /tools/give_pathways.py -i ${OUTPUT_UNION} -g /help_files/graphs.pkl -c /help_files/all_pathways_class.txt -n /help_files/all_pathways_names.txt -o ${OUTPUT} && \
echo "finish"