FROM alpine:3.7 as build

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN apk add --no-cache build-base ncurses-dev bzip2-dev xz-dev zlib-dev

# samtools and bgzip
RUN mkdir /samtools && \
    wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2 && \
    tar -xjf samtools-1.10.tar.bz2 && rm samtools-1.10.tar.bz2 && \
    cd samtools-1.10 && ./configure --prefix=/samtools && make && make install install-htslib

FROM alpine:3.7

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN apk add --no-cache pigz nodejs coreutils bash zlib bzip2 ncurses  \
    ncurses-dev bzip2-dev xz-dev zlib-dev && \
    mkdir /tools && mkdir /samtools

COPY --from=build /samtools /samtools

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
    /tools/

RUN chmod a+x /tools/*

ENV PATH="/samtools/bin:/tools:${PATH}"
