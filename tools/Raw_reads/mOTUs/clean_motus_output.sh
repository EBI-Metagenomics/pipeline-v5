motus=$1

grep -v "0$" $motus | tail -n+3 | sort -t$'\t' -k3,3n > $(basename -- $motus).tsv
tail -n1 $motus | sed s'/-1/Unmapped/g' >> $(basename -- $motus).tsv