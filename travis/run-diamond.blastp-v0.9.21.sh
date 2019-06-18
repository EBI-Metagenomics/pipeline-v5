#!/usr/bin/env bash

cd tools/Diamond
CMD="cwl-runner Diamon.blastp-v0.9.21.cwl Diamon.blastp-v0.9.21.test.job.yaml"
echo $CMD
$CMD