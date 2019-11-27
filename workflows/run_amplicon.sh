#!/usr/bin/bash

# Prepare env
echo "preparation"

source /hps/nobackup2/production/metagenomics/pipeline/testing/varsha/test_env.rc
export PATH=$PATH:/homes/emgpr/.nvm/versions/node/v12.10.0/bin/
export PATH=/hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda2-4.6.14/bin:$PATH
export CONDA_ENV=/hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda2-4.6.14/bin/activate
source /hps/nobackup2/production/metagenomics/pipeline/testing/kate/toil-3.19.0/bin/activate # 3.19 for profiling
#source /hps/nobackup2/production/metagenomics/pipeline/testing/kate/toil-memory/bin/activate
#source /hps/nobackup2/production/metagenomics/pipeline/tools-v5/toil-user-env/bin/activate

export WORK_DIR=/hps/nobackup2/production/metagenomics/pipeline/testing/kate_work
export OUT_DIR=/hps/nobackup2/production/metagenomics/pipeline/testing/kate_out
export MEMORY=40G

export NAME_RUN_1=profiling_amplicon
export CWL_1=/hps/nobackup2/production/metagenomics/pipeline/tools-v5/kate_test/pipeline-v5/workflows/amplicon-wf-single-empty.cwl
export YML=/hps/nobackup2/production/metagenomics/pipeline/tools-v5/kate_test/pipeline-v5/workflows/amplicon-wf-single-job.yml

export JOB_TOIL_FOLDER=$WORK_DIR/$NAME_RUN_1/
export LOG_DIR=${OUT_DIR}/logs_${NAME_RUN_1}
export TMPDIR=${WORK_DIR}/global-temp-dir_${NAME_RUN_1}
export OUT_TOOL=${OUT_DIR}/${NAME_RUN_1}

###  RUN
echo "pipeline"

mkdir -p $JOB_TOIL_FOLDER $LOG_DIR $TMPDIR $OUT_TOOL && \
cd $WORK_DIR && \
rm -rf $JOB_TOIL_FOLDER $OUT_TOOL/* $LOG_DIR/* && \
time toil-cwl-runner \
  --no-container \
  --batchSystem LSF \
  --disableCaching \
  --logDebug \
  --defaultMemory $MEMORY \
  --jobStore $JOB_TOIL_FOLDER \
  --outdir $OUT_TOOL \
  --logFile $LOG_DIR/${NAME_RUN_1}.log \
  --defaultCores 8 \
$CWL_1 $YML > $OUT_TOOL/out.json

echo "pipeline done"