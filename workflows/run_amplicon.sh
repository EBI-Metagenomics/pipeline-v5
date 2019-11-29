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
export MEMORY=30G

export TYPE=single
now=$(date +"%m_%d_%Y")
export NAME_RUN=amplicon-qc-${TYPE}_${now}
export CWL=/hps/nobackup2/production/metagenomics/pipeline/testing/kate/test_profiling/pipeline-v5/workflows/amplicon-wf-${TYPE}-v.5-qc.cwl
export YML=/hps/nobackup2/production/metagenomics/pipeline/testing/kate/test_profiling/pipeline-v5/workflows/amplicon-wf-${TYPE}-job.yml

export JOB_TOIL_FOLDER=$WORK_DIR/$NAME_RUN/
export LOG_DIR=${OUT_DIR}/logs_${NAME_RUN}
export TMPDIR=${WORK_DIR}/global-temp-dir_${NAME_RUN}
export OUT_TOOL=${OUT_DIR}/${NAME_RUN}

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
  --logFile $LOG_DIR/${NAME_RUN}.log \
  --defaultCores 8 \
$CWL $YML > $OUT_TOOL/out.json

echo "pipeline done"