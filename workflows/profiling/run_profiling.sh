#!/bin/bash

# Input: toil log-file
export LOG=

grep "memory used" ${LOG}| grep ".cwl" > ${LOG}_filt

python3 profiling_parser.py -i ${LOG}_filt

# output would be in [LOG.basename]_profiling_final_all.tsv (for all memory records)
# and [LOG.basename]_profiling_final_maximum.tsv (for max by each step)