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
        cwltest --test ${WORKDIR}/utils/tests.utils.yml \
          --timeout 1800 \
          --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container
    fi
    if [ "${TOOLS}" == "True" ]; then
        echo "Testing tools"
        cwltest --test ${WORKDIR}/tools/tests.tools.yml \
          -n 1-63 \
          --timeout 1800 \
          --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container
    fi
    if [ "${SUBWF}" == "True" ]; then
        echo "Testing subwfs"
        cwltest --test ${WORKDIR}/subworkflows/tests.subwf.yml \
          -n 1-31 \
          --timeout 10800 \
          --verbose --tool cwltool -- --preserve-entire-environment --enable-dev --no-container
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
         -n 1-16,18,20-25,27,30-31,33-36,38-40,42-45,47-57,60-71 \
         --timeout 1800 \
         --verbose --tool cwltool -- --preserve-entire-environment --enable-dev \
        --strict-memory-limit --singularity --leave-container

        # DOCKER FIXES 64-71
        # [17], [19], [28], [29], [46] - different headers because of file paths
        # [41], [58], [63] uses bgzip that does different gzipping
        # [59] antismash (names of contigs in embl and gbk files)
        # 26 - IPS (container doesn't work in Jenkins)
    fi
    if [ "${SUBWF}" == "True" ]; then
        echo "Testing subwfs without 8, 29, 30(IPS), 15-16 (antismash), 22 and 24 changed to 32 and 33"
        cwltest --test ${WORKDIR}/subworkflows/tests.subwf.yml \
        -n 1-7,9-14,17-21,23,25-28,31-33 \
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
