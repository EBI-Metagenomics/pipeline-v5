#!/usr/bin/env bash

fasta=$1
count=$2

if [ "$count" = 0 ]; then
 echo 'fasta is empty, set dummy'
 echo ">dummy_seq\nATCG" >> "$fasta" | mv "$fasta" 'empty_FASTQ.fasta'
else
  echo 'output original files'
  mv "$fasta" "$fasta"
fi

