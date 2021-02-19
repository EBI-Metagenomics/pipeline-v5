#!/bin/bash

source /hps/nobackup2/production/metagenomics/pipeline/tools-v5/auto_env.rc
source /hps/nobackup/production/metagenomics/software/cwltest/bin/activate

cwltest --test tests.utils.yml -n 1 \
--verbose --tool cwltool -- \
--preserve-entire-environment --enable-dev --no-container