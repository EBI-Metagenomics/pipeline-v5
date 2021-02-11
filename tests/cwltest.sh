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
        cwltest --test tools/tests.tools.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev \
        --strict-memory-limit --singularity \
        -n 1-16,18,20-25,27-28,30-31,33-36,38-40,42-44,47-57,61-65
        # without test 26 (IPS doesn't have docker yet)
        # 45 GenomeProperties YES/NO in table instead of 1/0
        # without test 59,60 (antismash doesn't have docker yet)

        echo "Testing tools docker"
        cwltest --test tools/docker.tests.tools.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev \
        --strict-memory-limit --singularity
        # 1 [17], 2 [19], 3 [28], 4 [29], 10 [46] - different headers because of file paths
        # 5 [32], 6 [37] prodigal - prints additional version to output files
        # 7 [41], 8 [58] uses bgzip that does different gzipping
        # 9 [45] GenomeProperties
        # 26, 59, 60 - IPS and antismash don't have docker containers in use
    fi
    if [ "${SUBWF}" == "True" ]; then
        echo "Testing subwfs"
        cwltest --test subworkflows/tests.subwf.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --strict-memory-limit --singularity
    fi
fi

# cwltest --tool cwltool -- --enable-dev --no-container --test tests.yml -j 4 --verbose -n 1

# cwltest --test tests/tests.yml "$@" --tool toil-cwl-runner -- --enable-dev --disableProgress
