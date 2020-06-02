#!/usr/bin/env bash

export DOCKER_USERNAME=mgnify
export DOCKER_PASSWORD=

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

docker push mgnify/pipeline-v5.python3:latest
docker push mgnify/pipeline-v5.python2:latest
docker push mgnify/pipeline-v5.bash-scripts:latest

# biom-convert 
docker push mgnify/pipeline-v5.biom-convert:latest
# mapseq
docker push mgnify/pipeline-v5.mapseq:latest
# mapseq2biom
docker push mgnify/pipeline-v5.mapseq2biom:latest
# cmsearch-deoverlap
docker push mgnify/pipeline-v5.cmsearch-deoverlap:latest
# krona
docker push mgnify/pipeline-v5.krona:latest
# cmsearch
docker push mgnify/pipeline-v5.cmsearch:latest
# trimmomatic
docker push mgnify/pipeline-v5.trimmomatic:latest
# easel
docker push mgnify/pipeline-v5.easel:latest
# SeqPrep
docker push mgnify/pipeline-v5.seqprep:latest

# mOUTs
docker push mgnify/pipeline-v5.motus:latest
# bedtools
docker push mgnify/pipeline-v5.bedtools:latest

# hmmer
docker push mgnify/pipeline-v5.hmmer:latest
# GO
docker push mgnify/pipeline-v5.go-summary:latest

# FragGeneScan
docker push mgnify/pipeline-v5.fraggenescan:latest
# Prodigal
docker push mgnify/pipeline-v5.prodigal:latest
# Prodigal + FGS post-processing
docker push mgnify/pipeline-v5.protein-post-processing:latest

# Genome properties
docker push mgnify/pipeline-v5.genome-properties:latest

# diamond
docker push mgnify/pipeline-v5.diamond:latest

# eggnog
docker push mgnify/pipeline-v5.eggnog:latest

# antismash
docker push mgnify/pipeline-v5.antismash:latest

# IPS
docker push mgnify/pipeline-v5.interproscan:latest