#!/usr/bin/env bash

coordinates=$1
stats=$2

y=($(wc -l $coordinates))
x=($(grep -m1 "sequence_count" $stats | cut -f 2)

bc <<< "scale=10; ($y/$x)"

###