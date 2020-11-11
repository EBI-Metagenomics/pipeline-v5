#!/usr/bin/env bash

mapseq=$1
otutable=$2
biomtable=$3
krona=$4
fasta=$5
otunotaxid=$6

# db=$(echo "$fasta" | cut -f 1 -d '.')
y=($( wc -l $mapseq))
if [ $y -eq 2 ]; then
  echo 'create empty files'
  touch empty.mseq empty.mseq.tsv empty.txt empty.html empty.fasta empty.notaxid.tsv
  cat $mapseq  >> empty.mseq
  cat $biomtable >> empty.txt
  cat $krona >> empty.html
  cat $fasta >> empty.fasta  # mv $fasta "empty.$db.fasta"
  cat $otutable >> empty.mseq.tsv && echo -e '\n1\t1\tsk__NONE' >> empty.mseq.tsv
  cat $otunotaxid >> empty.notaxid.tsv && echo -e '\n1\t1\tsk__NONE' >> empty.notaxid.tsv
else
  echo 'output original files'
  mv $mapseq $otutable $biomtable $krona $fasta $otunotaxid .
fi