#!/bin/bash

input=$1
output=$2

echo "}" >> ${input}
cp ${input} ${output}