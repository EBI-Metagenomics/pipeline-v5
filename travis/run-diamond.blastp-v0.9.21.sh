#!/usr/bin/env bash

cd tools/Diamond
CMD="cwl-runner Diamond.blastp-v0.9.21.cwl Diamond.blastp-v0.9.21.test.job.yaml"
echo $CMD
$CMD