#!/bin/bash

input=$1
output=$2
symbol=$3

echo ${symbol} >> ${input}
cp ${input} ${output}