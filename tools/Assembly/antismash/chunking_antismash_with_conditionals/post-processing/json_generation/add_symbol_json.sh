#!/bin/bash

input=$1
output=$2
symbol=$3
type=$4

if [ ${type} == "last" ]; then
    echo ${symbol} >> ${input}
    cp ${input} ${output}
elif [ ${type} == "first" ]; then
    touch ${output}_1
    echo ${symbol} > ${output}_1
    cat ${input} >> ${output}_1
    less ${output}_1 | tr '\n' ' ' > ${output}
fi