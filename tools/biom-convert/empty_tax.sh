#!/usr/bin/env bash

mapseq=$1
otutable=$2
biomtable=$3
krona=$4
fasta=$5

y=($( wc -l $mapseq))
if [ $y -eq 2 ]; then
 echo 'create empty files'
  mv $mapseq 'empty.mseq'
  echo -e "1\t1\tsk__NONE" >> $otutable | mv $otutable 'empty.tsv'
  mv $biomtable 'empty.txt'
  mv $krona 'empty.html'
  mv $fasta 'empty.fasta'
else
  echo 'output original files'
  mv $mapseq $otutable $biomtable $krona $fasta .
fi

