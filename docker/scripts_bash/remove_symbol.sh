#!/bin/bash

input=$1
output=$2
type=$3

if [ ${type} == "first" ]; then
    sed '1s/^.//' ${input} > ${output}
elif [ ${type} == "last" ]; then
    sed '$ s/.$//' ${input} > ${output}
else
   sed '$ s/.$//' ${input} | sed '1s/^.//' > ${output}
fi