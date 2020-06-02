FROM alpine:3.7

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

########################################################################
# Dockerfile Version:   19.03.1
# Software:             eggNOG
# Software Version:     2.0.0
# Description:          functional annotation of novel sequences
########################################################################

ENV VERSION=2.0.0
ENV VERSION_DIAMOND=0.9.24

RUN apk add --no-cache bash git
RUN apk add --no-cache build-base
RUN apk add --no-cache zlib-dev

# install diamond
RUN wget https://github.com/bbuchfink/diamond/archive/v$VERSION_DIAMOND.tar.gz && \
    tar -xzvf v$VERSION_DIAMOND.tar.gz && \
    cd diamond-$VERSION_DIAMOND && bash build_simple.sh
ENV PATH="/diamond-$VERSION_DIAMOND:${PATH}"

# eggnog
RUN wget https://github.com/eggnogdb/eggnog-mapper/archive/$VERSION.tar.gz && tar -xzvf $VERSION.tar.gz
ENV PATH="/eggnog-mapper-$VERSION/eggnogmapper:/eggnog-mapper-$VERSION:${PATH}"
RUN apk add --no-cache python

RUN rm /eggnog-mapper-$VERSION/bin/diamond && ln -s /diamond-$VERSION_DIAMOND/diamond /eggnog-mapper-$VERSION/bin/diamond
CMD [emapper.py]