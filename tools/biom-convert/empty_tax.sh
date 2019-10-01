#!/usr/bin/env bash

mapseq=$1
otutable=$2
biomtable=$3
krona=$4

count=($(wc -l $mapseq))
standard=$((`echo "$count = 2"| bc`))
if [ $standard -eq 1 ]; then
  echo 'create empty files'
  mv $mapseq 'empty.mseq'
  echo -e "1\t1\tsk__NONE" >> $otutable | mv $otutable 'empty.tsv'
  mv $biomtable 'empty.txt'
  mv krona 'empty.html'
else
  echo 'copy original files'
  cp $mapseq $mapseq
  cp $otutable $otutable
  cp $biomtable $biomtable
  cp $krona $krona
fi

