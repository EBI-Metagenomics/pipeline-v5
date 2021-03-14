#!/bin/bash

export WORKDIR=`pwd`

while getopts :c:t:u:s:w:p: option; do
	case "${option}" in
		c) CONTAINER=${OPTARG};;
		t) TOOLS=${OPTARG};;
		u) UTILS=${OPTARG};;
		s) SUBWF=${OPTARG};;
		w) WORKDIR=${OPTARG};;
		p) PIPELINE=${OPTARG};;
	esac
done

if [ "${CONTAINER}" == "False" ]; then
    if [ "${UTILS}" == "True" ]; then
        echo "Testing utils"
        cwltest --test ${WORKDIR}/utils/tests.utils.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container
    fi
    if [ "${TOOLS}" == "True" ]; then
        echo "Testing tools"
        cwltest --test ${WORKDIR}/tools/tests.tools.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container
    fi
    if [ "${SUBWF}" == "True" ]; then
        echo "Testing subwfs"
        cwltest --test ${WORKDIR}/subworkflows/tests.subwf.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container
    fi
    if [ "${PIPELINE}" == "True" ]; then
        echo "Testing whole wf"
        cwltest --test ${WORKDIR}/wf/tests.wf.yml --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container
    fi
else
    if [ "${UTILS}" == "True" ]; then
        echo "Testing utils"
        cwltest --test ${WORKDIR}/utils/tests.utils.yml --verbose --tool cwltool -- --preserve-entire-environment \
        --enable-dev --strict-memory-limit --singularity --leave-container
    fi
    if [ "${TOOLS}" == "True" ]; then
        echo "Testing tools"
        cwltest --test ${WORKDIR}/tools/tests.tools.yml \
         -n 1-16,18,20-25,27,30-31,33-36,38-40,42-44,47-57,60-66 \
         --verbose --tool cwltool -- --preserve-entire-environment --enable-dev \
        --strict-memory-limit --singularity --leave-container

        # without test 26 (IPS doesn't have docker yet)
        # 45 GenomeProperties YES/NO in table instead of 1/0
        # without test 59,60 (antismash doesn't have docker yet)

        echo "Testing tools docker"
        cwltest --test ${WORKDIR}/docker.tests.yml --verbose --tool cwltool -- --preserve-entire-environment \
        --enable-dev \
        --strict-memory-limit \
        --singularity \
        --leave-container
        # 1 [17], 2 [19], 3 [28], 4 [29], 10 [46] - different headers because of file paths
        # 5 [32], 6 [37] prodigal - prints additional version to output files
        # 7 [41], 8 [58], [63] uses bgzip that does different gzipping
        # 9 [45] GenomeProperties
        # 11 [59] antismash
        # 26 - IPS
    fi
    if [ "${SUBWF}" == "True" ]; then
        echo "Testing subwfs without IPS -n 1-7,9-28,31"
        cwltest --test ${WORKDIR}/subworkflows/tests.subwf.yml \
        -n 15-16 \
        --timeout 10800 \
        --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --strict-memory-limit --singularity --leave-container
    fi
    if [ "${PIPELINE}" == "True" ]; then
        echo "Testing wfs"
        cwltest --test {WORKDIR}/wf/tests.wf.yml \
        --timeout 10800 \
        --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --strict-memory-limit --singularity --leave-container
    fi
fi

# cwltest --tool cwltool -- --enable-dev --no-container --test tests.yml -j 4 --verbose -n 1

# cwltest --test tests/tests.yml "$@" --tool toil-cwl-runner -- --enable-dev --disableProgress
