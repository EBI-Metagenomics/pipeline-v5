#!/bin/bash

# Esl-ssplit wrapper - because Toil gives to input file a very long name

number_of_output_files=$1
same_number_of_residues=$2
seqs=$3
chunk_size=$4

f="copy-$(basename -- ${seqs})"
# echo "$f"

cp ${seqs} $f

if [[ ${number_of_output_files} == "True" && ${same_number_of_residues} == "True" ]]; then
    esl-ssplit.pl -n -r $f ${chunk_size}
    echo "1"
elif [[ ${number_of_output_files} == "False" && ${same_number_of_residues} == "True" ]]; then
    esl-ssplit.pl -r $f ${chunk_size}
    echo "2"
elif [[ ${number_of_output_files} == "True" && ${same_number_of_residues} == "False" ]]; then
    esl-ssplit.pl -n $f ${chunk_size}
    echo "3"
else
    esl-ssplit.pl $f ${chunk_size}
    echo "4"
fi

rm $f