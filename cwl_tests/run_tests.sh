#!/bin/bash

AS_PY_SCRIPT_PATH=$(readlink -f "../tools/Assembly/antismash/chunking_antismash_with_conditionals/post-processing/gff_antismash/")
PATH="${AS_PY_SCRIPT_PATH}":${PATH}

cwltest --test tests.yml --tool cwltool -- --no-container