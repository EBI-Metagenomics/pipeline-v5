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
RUN apk add --no-cache bash wget python3 git build-base \
    zlib-dev ncurses-dev bzip2-dev xz-dev

ENV VERSION=2.5.1
ENV ZIP=$VERSION.tar.gz

RUN wget https://github.com/motu-tool/mOTUs_v2/archive/$ZIP  \
  && tar xvzf $ZIP \
  && rm $ZIP

# hack for motus script - doesn't work with CWL version
#RUN cd mOTUs_v2-$VERSION \
#     && grep -Fn "relative_path = relative_path" motus | tr ':' '\t' | cut -f1 > number \
#     && T=$(cat number) \
#     && NEW_PATH=/mOTUs_v2-$VERSION \
#     && sed -i "${T}s/.*/relative_path=\"\/mOTUs_v2-2.5.1\/\"/g" motus

# BWA
RUN git clone https://github.com/lh3/bwa.git && cd bwa && make
ENV PATH="/bwa:${PATH}"

# samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2 && \
    tar -xjf samtools-1.10.tar.bz2 && rm samtools-1.10.tar.bz2 && \
    cd samtools-1.10 && ./configure && make && make install

# DB-mOTUs
RUN python3 mOTUs_v2-$VERSION/setup.py
RUN chmod a+r /mOTUs_v2-$VERSION/db_mOTU/*

# change shebang to python3
RUN cd mOTUs_v2-$VERSION && sed -i -e '1 s|.*|#!/usr/bin/env python3|' motus

# check motus tests
RUN ln -s /usr/bin/python3 /usr/bin/python

ENV PATH="/usr/bin:/mOTUs_v2-$VERSION:${PATH}"
CMD ["motus"]