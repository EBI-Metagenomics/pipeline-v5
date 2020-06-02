FROM python:3

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN pip install --upgrade pip
RUN pip install -q biopython pandas networkx
RUN pip install -q pyyaml

COPY build_assembly_gff.py \
     give_pathways.py  \
     get_subunits_coords.py \
     get_subunits.py \
     functional_stats.py \
     write_summaries.py \
     its-length.py \
     split_to_chunks.py \
     run_result_file_chunker.py chunkFastaResultFileUtil.py chunkTSVFileUtil.py cleaningUtils.py \
     make_csv.py \
     hmmscan_tab.py \
     generate_checksum.py \
     fastq_to_fasta.py \
     parsing_hmmscan.py \
     count_fastq.py \
/tools/

RUN chmod a+x /tools/*

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools

