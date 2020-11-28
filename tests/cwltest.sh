#!/bin/bash

cwltest --tool cwltool -- --enable-dev --no-container --test tests.yml -j 4 --verbose -n 1

# cwltest --test tests/tests.yml "$@" --tool toil-cwl-runner -- --enable-dev --disableProgress
