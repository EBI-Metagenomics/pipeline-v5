FROM ubuntu:20.04

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

########################################################################
# Dockerfile Version:   19.03.1
# Software:             Diamond
# Software Version:     0.9.25
# Description:          sequence aligner
########################################################################
LABEL based="https://github.com/bbuchfink/diamond/blob/v0.9.25/Dockerfile"

ENV VERSION=0.9.25

RUN apt-get update && \
    apt-get install -y make pbuilder python-mock python-configobj python-support cdbs devscripts build-essential \
    git zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get install --reinstall python-pkg-resources

RUN wget -q https://github.com/bbuchfink/diamond/archive/v$VERSION.tar.gz && \
    tar -zxf v$VERSION.tar.gz && \
    cd diamond-$VERSION && bash build_simple.sh

COPY --from=build-diamond /usr/local/bin/diamond /usr/local/bin/diamond

CMD ["diamond"]