#!/bin/bash

set -e

DOCKER_ORG="microbiomeinformatics"

BASE_PATH=$(dirname "$(pwd)")

########### python3 ###########
# - build_assembly_gff.py
# - give_pathways.py
# - get_subunits_coords.py
# - get_subunits.py
# - functional_stats.py
# - write_summaries.py
# - its-length-new.py
# - split_to_chunks.py
# - chunking: chunkFastaResultFileUtil.py, chunkTSVFileUtil.py, cleaningUtils.py, run_result_file_chunker.py
# - make_csv.py
# - hmmscan_tab.py
# - generate_checksum.py
# - fastq_to_fasta.py
docker build -t ${DOCKER_ORG}/pipeline-v5.python3:v1 "${BASE_PATH}"/docker/scripts_python3

########### python2 ###########
# - MGRAST_base.py
# - run_quality_filtering.py
docker build -t ${DOCKER_ORG}/pipeline-v5.python2:v1 "${BASE_PATH}"/docker/scripts_python2

########### bash ###########
# - empty_tax.sh
# - biom-convert.sh
# - diamond_post_run_join.sh
# - awk_tool
# - pull_ncrna.sh
# - format_bedfile
# - pigz
# - add_header
# - run_samtools.sh
# - clean_motus_output.sh
docker build -t ${DOCKER_ORG}/pipeline-v5.bash-scripts:v1.2 "${BASE_PATH}"/docker/scripts_bash/

exit 0

########### Tools ###########

TOOLS=(
    "biom-convert:v2.1.6 ${BASE_PATH}/tools/RNA_prediction/biom-convert"
    "mapseq:v1.2.3 ${BASE_PATH}/tools/RNA_prediction/mapseq"
    "mapseq2biom:v1.0 ${BASE_PATH}/tools/RNA_prediction/mapseq2biom"
    "cmsearch-deoverlap:v0.02 ${BASE_PATH}/tools/RNA_prediction/cmsearch-deoverlap"
    "krona:2.7.1 ${BASE_PATH}/tools/RNA_prediction/krona"
    "cmsearch:v1.1.2 ${BASE_PATH}/tools/RNA_prediction/cmsearch"
    "trimmomatic:v0.36 ${BASE_PATH}/tools/Trimmomatic"
    "easel:v0.45h ${BASE_PATH}/tools/RNA_prediction/easel"
    "seqprep:v1.2 ${BASE_PATH}/tools/SeqPrep"
    "motus:v2.5.1 ${BASE_PATH}/tools/Raw_reads/mOTUs"
    "bedtools:v2.28.0 ${BASE_PATH}/tools/mask-for-ITS/bedtools"
    "hmmer:v3.2.1 ${BASE_PATH}/tools/hmmer"
    "go-summary:v1.0 ${BASE_PATH}/tools/GO-slim"
    "fraggenescan:v1.31 ${BASE_PATH}/tools/Combined_gene_caller/FragGeneScan"
    "prodigal:v2.6.3 ${BASE_PATH}/tools/Combined_gene_caller/Prodigal"
    "protein-post-processing:v1.0 ${BASE_PATH}/tools/Combined_gene_caller"
    "genome-properties:v2.0.1 ${BASE_PATH}/tools/Assembly/Genome_properties"
    "diamond:v0.9.25 ${BASE_PATH}/tools/Assembly/Diamond"
    "eggnog:v2.0.0 ${BASE_PATH}/tools/Assembly/EggNOG/eggNOG"
    "dna_chunking:v0.11 ${BASE_PATH}/tools/chunks/dna_chunker"
    "seqprep:v1.2 ${BASE_PATH}/tools/SeqPrep/Dockerfile"
    "split-fasta:v1 ${BASE_PATH}/utils/result-file-chunker/Dockerfile"
    "fastp:0.20.0 ${BASE_PATH}/utils/fastp/Dockerfile"
)

# containers that are too heavy to be used, it's possible but not recommended.
# "antismash:v4.2.0 ${BASE_PATH}/tools/Assembly/antismash/chunking_antismash_with_conditionals"
# "interproscan:v5.36-75.0 ${BASE_PATH}/tools/InterProScan"

for KEY in "${!TOOLS[@]}"
do
    echo "=============================================="
    echo "## Building ${TOOLS[$KEY]}"
    set -x
    # shellcheck disable=SC2086
    docker build -t "${DOCKER_ORG}"/pipeline-v5.${TOOLS[$KEY]//\"/}
    set +x
    echo ""
    echo ""
    echo "=============================================="
done

echo "Done."