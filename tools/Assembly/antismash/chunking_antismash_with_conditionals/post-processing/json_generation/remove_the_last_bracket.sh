#!/bin/bash

input=$1
output=$2

sed '$ s/.$//' ${input} > ${output}