#!/usr/bin/env bash

motus=$1

outfilename=$(basename -- "$motus").tsv
echo 'clean files'
echo -e '#mOTU\tconsensus_taxonomy\tcount' > $outfilename
grep -v "0$" $motus | egrep '^meta_mOTU|^ref_mOTU'  | sort -t$'\t' -k3,3n >> $outfilename
tail -n1 $motus | sed s'/-1/Unmapped/g' >> $outfilename

y=$(cat $outfilename | wc -l)
echo 'number of lines is' $y
if [ $y -eq 2 ]; then
  echo 'rename file to empty'
  mv $outfilename 'empty.motus.tsv'
fi
