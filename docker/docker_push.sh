#!/usr/bin/env bash

DOCKER_ORG="microbiomeinformatics"

DOCKER_IMAGES=(
    "python3:v1"
    "python2:v1"
    "bash-scripts:v1.1"
    "biom-convert:v2.1.6"
    "mapseq:v1.2.3"
    "mapseq2biom:v1.0"
    "cmsearch-deoverlap:v0.02"
    "krona:v2.7.1"
    "cmsearch:v1.1.2"
    "trimmomatic:v0.36"
    "easel:v0.45h"
    "seqprep:v1.2"
    "motus:v2.5.1"
    "bedtools:v2.28.0"
    "hmmer:v3.2.1"
    "go-summary:v1.0"
    "fraggenescan:v1.31"
    "prodigal:v2.6.3"
    "protein-post-processing:v1.0"
    "genome-properties:v2.0.1"
    "diamond:v0.9.25"
    "eggnog:v2.0.0"
    "dna_chunking:v0.11"
    "seqprep:v1.2"
)

# containers that are too heavy to be used, it's possible but not recommended.
# "antismash:v4.2.0"
# "interproscan:v5.36-75.0"

for IMG in "${DOCKER_IMAGES[@]}"
do
    docker push "${DOCKER_ORG}"/pipeline-v5."${IMG}"
done
