FROM ubuntu:20.04 as build

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN apt-get update
RUN apt-get install --yes \
  build-essential \
  git && \
  rm -rf /var/lib/apt/lists/*

ENV SAMTOOLS_VERSION=1.9

# samtools and bgzip
RUN mkdir /samtools && \
    wget https://github.com/samtools/samtools/releases/download/$SAMTOOLS_VERSION/samtools-$SAMTOOLS_VERSION.tar.bz2 && \
    tar -xjf samtools-$SAMTOOLS_VERSION.tar.bz2 && rm samtools-$SAMTOOLS_VERSION.tar.bz2 && \
    cd samtools-$SAMTOOLS_VERSION && ./configure --prefix=/samtools && make && make install install-htslib

FROM alpine:3.7

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN apk add --no-cache pigz nodejs coreutils bash zlib bzip2 ncurses  \
    ncurses-dev bzip2-dev xz-dev zlib-dev && \
    mkdir /tools && mkdir /samtools

COPY --from=build /samtools /samtools

COPY run_samtools_docker.sh /tools/

RUN chmod a+x /tools/*

ENV PATH="/samtools/bin:/tools:${PATH}"
