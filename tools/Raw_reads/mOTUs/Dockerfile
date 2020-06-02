FROM alpine:3.7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##########################################################################
# Dockerfile Version:   19.03.1
# Software:             mOTUs
# Software Version:     2.5.1
# Description:          Estimates relative abundance of known
#                       and currently unknown microbial community
#                       members using metagenomic shotgun sequencing data
##########################################################################
RUN apk add --no-cache bash wget

ENV VERSION=2.5.1

ENV ZIP=$VERSION.tar.gz

RUN wget https://github.com/motu-tool/mOTUs_v2/archive/$ZIP  \
  && tar xvzf $ZIP \
  && rm $ZIP

RUN apk add --no-cache python3
RUN python3 mOTUs_v2-$VERSION/setup.py
# change shebang to python3
RUN cd mOTUs_v2-$VERSION && sed -i -e '1 s|.*|#!/usr/bin/env python3|' motus

# BWA
RUN apk add --no-cache git
RUN apk add --no-cache build-base
RUN apk add --no-cache zlib-dev
RUN git clone https://github.com/lh3/bwa.git && cd bwa && make
ENV PATH="/bwa:${PATH}"

# samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2 && \
    tar -xvjf samtools-1.10.tar.bz2 && rm samtools-1.10.tar.bz2
RUN apk add --no-cache ncurses-dev bzip2-dev xz-dev
RUN cd samtools-1.10 && ./configure && make && make install

# check motus tests
RUN ln -s /usr/bin/python3 /usr/bin/python
ENV PATH="/usr/bin:/mOTUs_v2-$VERSION:${PATH}"
# RUN python3 mOTUs_v2-$VERSION/test.py

RUN chmod a+r /mOTUs_v2-$VERSION/db_mOTU/*
CMD ["motus"]