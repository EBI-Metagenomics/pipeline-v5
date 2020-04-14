#!/bin/bash

while getopts i:o:g:n:f: option; do
	case "${option}" in
		i) INPUT=${OPTARG};;
		o) OUTFOLDER=${OPTARG};;
		g) GLOSSARY=${OPTARG};;
		n) OUTNAME=${OPTARG};;
		f) FINAL_FOLDER=${OPTARG};;
	esac
done

mkdir -p ${FINAL_FOLDER}

grep '>' ${INPUT} | wc -l > value.txt
LENGTH=`< value.txt`

if (( $LENGTH > 0 )); then
    echo "run antismash"
    source ${CONDA_ENV} antismash && \
    antismash \
      -v \
      --smcogs  \
      -c 4  \
      --borderpredict  \
      --asf  \
      --inclusive  \
      --outputfolder ${OUTFOLDER} \
      ${INPUT}  # --transatpks_da

    if [ $? -eq 0 ]
    then
        echo "run json generation"
        antismash_json_generation -o geneclusters.json -i ${OUTFOLDER}/geneclusters.js

        echo "run reformat clusters"
        reformat-antismash.py -g ${GLOSSARY} -a ${OUTFOLDER}/geneclusters.txt

        echo "GFF generation"
        antismash_to_gff.py -g geneclusters-summary.txt -e ${OUTFOLDER}/*final.embl -j geneclusters.json -o ${OUTNAME}.antismash.gff

        echo "rename files"
        mv ${OUTFOLDER}/*final.embl ${OUTNAME}_antismash_final.embl
        mv ${OUTFOLDER}/*final.gbk ${OUTNAME}_antismash_final.gbk
        mv geneclusters-summary.txt ${OUTNAME}_antismash_geneclusters.txt

        echo "gzip embl and gbk"
        gzip ${OUTNAME}_antismash_final.gbk ${OUTNAME}_antismash_final.embl

        echo "move to pathways-systems"
        mv ${OUTNAME}_antismash_final.embl.gz ${OUTNAME}_antismash_final.gbk.gz ${OUTNAME}_antismash_geneclusters.txt ${OUTNAME}.antismash.gff.bgz ${OUTNAME}.antismash.gff.bgz.tbi ${FINAL_FOLDER}
    else
        touch ${FINAL_FOLDER}/antismash_failed
    fi
else
    touch ${FINAL_FOLDER}/no_antismash
fi

