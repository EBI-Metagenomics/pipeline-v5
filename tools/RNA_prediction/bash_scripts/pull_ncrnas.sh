#!/usr/bin/env bash

hits=$1
model=${@:2}

for x in $model
do
  if grep -q $x $hits; then
    grep $string $hits > $string.hits
  fi
done

