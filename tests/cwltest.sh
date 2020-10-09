#!/bin/bash

cwltest --test tests/tests.yml "$@" --tool toil-cwl-runner -- --enable-dev --disableProgress
