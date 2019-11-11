#!/usr/bin/env bash

motus=$1

echo 'clean files'
grep -v "0$" $motus | tail -n+3 | sort -t$'\t' -k3,3n > $(basename -- $motus).tsv
tail -n1 $motus | sed s'/-1/Unmapped/g' >> $(basename -- $motus).tsv

y=$( wc -l $(basename -- $motus).tsv)
if [ $y -eq 2 ]; then
  echo 'rename file to empty'
  mv $(basename -- $motus).tsv 'empty.motus.tsv'
fi