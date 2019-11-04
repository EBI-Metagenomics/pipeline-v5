#!/usr/bin/env bash

hits=$1
model=${@:2}

for x in $model
do
  string=$(basename $x | cut -d. -f1)
  if grep -q $string $hits; then
    grep $string $hits > $string.hits
  fi
done

