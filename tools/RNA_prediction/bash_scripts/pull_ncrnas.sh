#!/usr/bin/env bash

hits=$1
model=$2
string=$(basename $model | cut -d. -f1)
if grep -q $string $hits; then
  grep $string $hits
else
  touch $string.hits
fi


