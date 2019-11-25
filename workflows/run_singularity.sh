#!/bin/bash

export PATH=/usr/lib64/qt-3.3/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/ebi/lsf/ebi/10.1/linux3.10-glibc2.17-x86_64/bin:$PATH
source /hps/nobackup2/production/metagenomics/pipeline/tools-v5/test_env.rc
export PATH=$PATH:/homes/emgpr/.nvm/versions/node/v12.10.0/bin/
export PATH=/hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda2-4.6.14/bin:$PATH
export PERL5LIB=/homes/emgpr/perl5/lib/perl5:/hps/nobackup2/production/metagenomics/pipeline/tools-v5/genome-properties/code/modules:$PERL5LIB
export CONDA_ENV=/hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda2-4.6.14/bin/activate
source /hps/nobackup2/production/metagenomics/pipeline/tools-v5/toil-user-env/bin/activate

export WORK_DIR=/hps/nobackup2/production/metagenomics/pipeline/testing/kate_work
export OUT_DIR=/hps/nobackup2/production/metagenomics/pipeline/testing/kate_out
export MEMORY=20G

export NAME_RUN=assembly_new_chunking
export CWL=/hps/nobackup2/production/metagenomics/pipeline/testing/kate/pipeline-v5/tools/biom-convert/biom-convert.cwl
export YML=/hps/nobackup2/production/metagenomics/pipeline/testing/kate/pipeline-v5/tools/biom-convert/biom-convert-test.job-input.yml


export JOB_TOIL_FOLDER=$WORK_DIR/$NAME_RUN/
export LOG_DIR=${OUT_DIR}/logs_${NAME_RUN}
export TMPDIR=${WORK_DIR}/global-temp-dir_${NAME_RUN}
export OUT_TOOL=${OUT_DIR}/${NAME_RUN}


mkdir -p $JOB_TOIL_FOLDER $LOG_DIR $TMPDIR $OUT_TOOL && \
cd $WORK_DIR && \
rm -rf $JOB_TOIL_FOLDER $OUT_TOOL/* $LOG_DIR/* && \
time cwltoil \
  --singularity \
  --defaultCores 8 \
  --batchSystem LSF \
  --disableCaching \
  --logDebug \
  --defaultMemory $MEMORY \
  --jobStore $JOB_TOIL_FOLDER \
  --outdir $OUT_TOOL \
  --logFile $LOG_DIR/${NAME_RUN}.log \
  --writeLogs $LOG_DIR \
$CWL $YML