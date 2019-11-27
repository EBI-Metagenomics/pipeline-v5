#!/bin/bash

# < common part >
# --> env
export PATH=/usr/lib64/qt-3.3/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/ebi/lsf/ebi/10.1/linux3.10-glibc2.17-x86_64/bin:$PATH
source /hps/nobackup2/production/metagenomics/pipeline/tools-v5/test_env.rc
export PATH=$PATH:/homes/emgpr/.nvm/versions/node/v12.10.0/bin/
export PATH=/hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda2-4.6.14/bin:$PATH
export PERL5LIB=/homes/emgpr/perl5/lib/perl5:/hps/nobackup2/production/metagenomics/pipeline/tools-v5/genome-properties/code/modules:$PERL5LIB
export CONDA_ENV=/hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda2-4.6.14/bin/activate
source /hps/nobackup2/production/metagenomics/pipeline/tools-v5/toil-user-env/bin/activate
# --> Toil memory and cores
export MEMORY=20G
export NUM_CORES=8

# < variable testing part >
# --> dirs
export WORK_DIR=/hps/nobackup2/production/metagenomics/pipeline/testing/kate_work
export OUT_DIR=/hps/nobackup2/production/metagenomics/pipeline/testing/kate_out
export PIPELINE_FOLDER=/hps/nobackup2/production/metagenomics/pipeline/tools-v5/kate_test/pipeline-v5
# --> run files
export YML=$PIPELINE_FOLDER/workflows/raw-reads-single-job.yml
export PARSER_SCRIPT=$PIPELINE_FOLDER/workflows/conditionals/out_json_parser.py

export NAME_RUN=wgs-qc
export CWL_1=$PIPELINE_FOLDER/workflows/conditionals/raw_reads/raw-reads-single-1.cwl
export CWL_2=$PIPELINE_FOLDER/workflows/conditionals/raw_reads/raw-reads-2.cwl

# < set up folders >
export JOB_TOIL_FOLDER=$WORK_DIR/$NAME_RUN/
export LOG_DIR=${OUT_DIR}/logs_${NAME_RUN}
export TMPDIR=${WORK_DIR}/global-temp-dir_${NAME_RUN}
echo "run first part"
export NAME_RUN_1=${NAME_RUN}_1
export OUT_TOOL_1=${OUT_DIR}/${NAME_RUN_1}

mkdir -p $JOB_TOIL_FOLDER $LOG_DIR $TMPDIR $OUT_TOOL_1 && \
cd $WORK_DIR && \
rm -rf $JOB_TOIL_FOLDER $OUT_TOOL_1/* $LOG_DIR/* && \
time cwltoil \
  --no-container \
  --batchSystem LSF \
  --disableCaching \
  --defaultMemory $MEMORY \
  --jobStore $JOB_TOIL_FOLDER \
  --outdir $OUT_TOOL_1 \
  --logFile $LOG_DIR/${NAME_RUN_1}.log \
  --defaultCores $NUM_CORES \
$CWL_1 $YML > $OUT_TOOL_1/out1.json

echo "first part done. Parsing output json"
python3 $PARSER_SCRIPT -j $OUT_TOOL_1/out1.json -y $YML -m "raw-reads"

if [ $? -eq 1 ]
then
    echo "success. Run second part"
    export NAME_RUN_2=${NAME_RUN}_2
    export OUT_TOOL_2=${OUT_DIR}/${NAME_RUN_2}

    mkdir -p $OUT_TOOL_2 && \
    cd $WORK_DIR && \
    rm -rf $OUT_TOOL_2/* && \
    time cwltoil \
      --no-container \
      --batchSystem LSF \
      --disableCaching \
      --defaultMemory $MEMORY \
      --jobStore $JOB_TOIL_FOLDER \
      --outdir $OUT_TOOL_2 \
      --logFile $LOG_DIR/${NAME_RUN_2}.log \
      --defaultCores $NUM_CORES \
    $CWL_2 $YML > $OUT_TOOL_2/out2.json

    echo "done"
else
    echo "failed"
fi

echo "move first part"
mkdir -p ${OUT_DIR}/${NAME_RUN} && rm -rf ${OUT_DIR}/${NAME_RUN}/*
mv ${OUT_TOOL_1}/* ${OUT_DIR}/${NAME_RUN} && rm -rf ${OUT_TOOL_1}
if [ -d ${OUT_TOOL_2} ]
then
    echo "move second part"
    mv ${OUT_TOOL_2}/* ${OUT_DIR}/${NAME_RUN} && rm -rf ${OUT_TOOL_2}
fi

echo "PIPELINE DONE"
