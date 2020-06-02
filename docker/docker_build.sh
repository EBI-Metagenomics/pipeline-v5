#!/bin/bash

export PIPELINE=`pwd`/..

########### python3 ###########
# - build_assembly_gff.py
# - give_pathways.py
# - get_subunits_coords.py
# - get_subunits.py
# - functional_stats.py
# - write_summaries.py
# - its-length.py
# - split_to_chunks.py
# - chunking: chunkFastaResultFileUtil.py, chunkTSVFileUtil.py, cleaningUtils.py, run_result_file_chunker.py
# - make_csv.py
# - hmmscan_tab.py
# - generate_checksum.py
# - fastq_to_fasta.py
docker build -t mgnify/pipeline-v5.python3 ${PIPELINE}/docker/scripts_python3

########### python2 ###########
# - MGRAST_base.py
# - run_quality_filtering.py
docker build -t mgnify/pipeline-v5.python2 ${PIPELINE}/docker/scripts_python2

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
docker build -t mgnify/pipeline-v5.bash-scripts ${PIPELINE}/docker/scripts_bash/


########### Tools ###########

# biom-convert
docker build -t mgnify/pipeline-v5.biom-convert ${PIPELINE}/tools/RNA_prediction/biom-convert
# mapseq
docker build -t mgnify/pipeline-v5.mapseq ${PIPELINE}/tools/RNA_prediction/mapseq
# mapseq2biom
docker build -t mgnify/pipeline-v5.mapseq2biom ${PIPELINE}/tools/RNA_prediction/mapseq2biom
# cmsearch-deoverlap: biocrusoe/cmsearch-deoverlap
docker build -t mgnify/pipeline-v5.cmsearch-deoverlap ${PIPELINE}/tools/RNA_prediction/cmsearch-deoverlap
# krona
docker build -t mgnify/pipeline-v5.krona ${PIPELINE}/tools/RNA_prediction/krona
# cmsearch: quay.io/biocontainers/infernal:1.1.2--h470a237_1
docker build -t mgnify/pipeline-v5.cmsearch ${PIPELINE}/tools/RNA_prediction/cmsearch
# trimmomatic
docker build -t mgnify/pipeline-v5.trimmomatic ${PIPELINE}/tools/Trimmomatic
# easel: quay.io/biocontainers/hmmer:3.2.1--hf484d3e_1
docker build -t mgnify/pipeline-v5.easel ${PIPELINE}/tools/RNA_prediction/easel
# SeqPrep: quay.io/biocontainers/seqprep:1.1--1
docker build -t mgnify/pipeline-v5.seqprep ${PIPELINE}/tools/SeqPrep

# mOUTs: quay.io/biocontainers/motus:2.1.1--py37_3
docker build -t mgnify/pipeline-v5.motus ${PIPELINE}/tools/Raw_reads/mOTUs
# bedtools: quay.io/biocontainers/bedtools:2.28.0--hdf88d34_0
docker build -t mgnify/pipeline-v5.bedtools ${PIPELINE}/tools/mask-for-ITS/bedtools

# hmmer quay.io/biocontainers/hmmer:3.2.1--hf484d3e_1
docker build -t mgnify/pipeline-v5.hmmer ${PIPELINE}/tools/hmmscan
# GO
docker build -t mgnify/pipeline-v5.go-summary ${PIPELINE}/tools/GO-slim

# FragGeneScan
docker build -t mgnify/pipeline-v5.fraggenescan ${PIPELINE}/tools/Combined_gene_caller/FragGeneScan
# Prodigal
docker build -t mgnify/pipeline-v5.prodigal ${PIPELINE}/tools/Combined_gene_caller/Prodigal
# Prodigal + FGS post-processing
docker build -t mgnify/pipeline-v5.protein-post-processing ${PIPELINE}/tools/Combined_gene_caller

# Genome properties
docker build -t mgnify/pipeline-v5.genome-properties ${PIPELINE}/tools/Assembly/Genome_properties

# diamond: "buchfink/diamond:version0.9.30" (in production v9.25)
docker build -t mgnify/pipeline-v5.diamond ${PIPELINE}/tools/Assembly/Diamond

# eggnog
docker build -t mgnify/pipeline-v5.eggnog ${PIPELINE}/tools/Assembly/EggNOG/eggNOG

# antismash
docker build -t mgnify/pipeline-v5.antismash ${PIPELINE}/tools/Assembly/antismash

# IPS: biocontainers/interproscan:v5.30-69.0_cv1
docker build -t mgnify/pipeline-v5.interproscan ${PIPELINE}/tools/InterProScan