#!/bin/bash

while getopts :c:t:u:s: option; do
	case "${option}" in
		c) CONTAINER=${OPTARG};;
		t) TOOLS=${OPTARG};;
		u) UTILS=${OPTARG};;
		s) SUBWF=${OPTARG};;
	esac
done

if [ "${CONTAINER}" == "False" ]; then
    if [ "${UTILS}" == "True" ]; then
        echo "Testing utils"
        cwltest --test utils/tests.utils.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container
    fi
    if [ "${TOOLS}" == "True" ]; then
        echo "Testing tools"
        cwltest --test tools/tests.tools.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container
    fi
    if [ "${SUBWF}" == "True" ]; then
        echo "Testing subwfs"
        cwltest --test subworkflows/tests.subwf.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container
    fi
else
    if [ "${UTILS}" == "True" ]; then
        echo "Testing utils"
        cwltest --test utils/tests.utils.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --strict-memory-limit --singularity
    fi
    if [ "${TOOLS}" == "True" ]; then
        echo "Testing tools"
        cwltest --test tools/tests.tools.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --strict-memory-limit --singularity
    fi
    if [ "${SUBWF}" == "True" ]; then
        echo "Testing subwfs"
        cwltest --test subworkflows/tests.subwf.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --strict-memory-limit --singularity
    fi
fi

# cwltest --tool cwltool -- --enable-dev --no-container --test tests.yml -j 4 --verbose -n 1

# cwltest --test tests/tests.yml "$@" --tool toil-cwl-runner -- --enable-dev --disableProgress
