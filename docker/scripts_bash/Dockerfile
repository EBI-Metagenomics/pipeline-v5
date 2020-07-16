FROM alpine:3.7

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
RUN apk add --no-cache bash

COPY add_header \
     add_symbol_json.sh \
     antismash_json_generation \
     awk_tool \
     biom-convert.sh \
     clean_motus_output.sh \
     diamond_post_run_join.sh \
     empty_tax.sh \
     format_bedfile \
     pull_ncrnas.sh \
     run_antismash_short.sh \
     run_samtools.sh \
     remove_symbol.sh \
     esl-ssplit.sh \
/tools/

RUN chmod a+x /tools/*

# samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2 && \
    tar -xvjf samtools-1.10.tar.bz2 && rm samtools-1.10.tar.bz2

RUN apk add --no-cache build-base
RUN apk add --no-cache ncurses-dev bzip2-dev xz-dev
RUN apk add --no-cache zlib-dev
RUN cd samtools-1.10 && ./configure && make && make install

# bgzip
RUN wget https://github.com/samtools/htslib/releases/download/1.2.1/htslib-1.2.1.tar.bz2 && tar xvf htslib-1.2.1.tar.bz2
RUN cd htslib-1.2.1 && make && make install

# pigz
RUN apk add --no-cache pigz

# NodeJS
RUN apk add nodejs

RUN apk add --no-cache coreutils

ENV PATH="/tools:${PATH}"