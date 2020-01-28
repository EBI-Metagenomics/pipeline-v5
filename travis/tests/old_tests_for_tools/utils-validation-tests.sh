#!/usr/bin/env bash
export PATH="$HOME/node-v8.11.1:$PATH"

set -e



for i in $(find utils -name "*.cwl"); do
 echo "Testing: ${i}"
 cwltool --validate ${i}
done