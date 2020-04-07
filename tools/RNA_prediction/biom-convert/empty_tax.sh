#!/usr/bin/env bash

mapseq=$1
otutable=$2
biomtable=$3
krona=$4
fasta=$5
otunotaxid=$6

db=$(echo "$filename" | cut -f 1 -d '.')
y=($( wc -l $mapseq))
if [ $y -eq 2 ]; then
 echo 'create empty files'
  mv $mapseq 'empty.mseq'
  echo -e "1\t1\tsk__NONE" >> $otutable | mv $otutable 'empty.mseq.tsv'
  mv $biomtable 'empty.txt'
  mv $krona 'empty.html'
  mv $fasta "empty.$db.fasta"
  echo -e "1\t1\tsk__NONE" >> $otunotaxid | mv $otunotaxid 'empty.notaxid.tsv'
else
  echo 'output original files'
  mv $mapseq $otutable $biomtable $krona $fasta $otunotaxid .
fi

