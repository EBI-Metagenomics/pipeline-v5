#!/bin/bash

echo "Testing utils"
cwltest --test utils/tests.utils.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container

echo "Testing tools"
cwltest --test tools/tests.tools.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container

# cwltest --tool cwltool -- --enable-dev --no-container --test tests.yml -j 4 --verbose -n 1

# cwltest --test tests/tests.yml "$@" --tool toil-cwl-runner -- --enable-dev --disableProgress
