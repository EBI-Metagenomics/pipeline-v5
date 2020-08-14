#!/bin/bash

cwltest --test tests.yml --test tests.yml "$@" --tool toil-cwl-runner -- --enable-dev --disableProgress
