FROM python:3

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN pip install --upgrade pip
RUN pip install -q biopython pandas networkx
RUN pip install -q pyyaml

COPY antismash_to_gff.py \
     build_assembly_gff.py \
     count_fastq.py \
     count_lines.py \
     fastq_to_fasta.py \
     functional_stats.py \
     generate_checksum.py \
     give_pathways.py  \
     get_subunits_coords.py \
     get_subunits.py \
     hmmscan_tab.py \
     its-length.py \
     make_csv.py \
     move_antismash_summary.py \
     parsing_hmmscan.py \
     reformat-antismash.py \
     split_to_chunks.py \
     run_result_file_chunker.py chunkFastaResultFileUtil.py chunkTSVFileUtil.py cleaningUtils.py \
     write_summaries.py \
/tools/

RUN chmod a+x /tools/*

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools

