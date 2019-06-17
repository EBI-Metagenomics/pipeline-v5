#!/usr/bin/env bash
export PATH="$HOME/node-v8.11.1:$PATH"
export PATH="$HOME/miniconda/bin:$PATH"
source activate cwl-environment

set -e

# run a conformance test for all CWL descriptions

for i in $(find workflows -name "*.cwl"); do
 echo "Testing: ${i}"
 cwltool --validate ${i}
done