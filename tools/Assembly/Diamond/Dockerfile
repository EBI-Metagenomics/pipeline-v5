FROM ubuntu:14.04

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

########################################################################
# Dockerfile Version:   19.03.1
# Software:             Diamond
# Software Version:     0.9.25
# Description:          sequence aligner
########################################################################

ENV VERSION=0.9.25

RUN apt-get update
RUN apt-get install -y make pbuilder python-mock python-configobj python-support cdbs devscripts build-essential
RUN apt-get install -y git
RUN apt-get install --reinstall python-pkg-resources
RUN apt-get install zlib1g-dev
RUN wget https://github.com/bbuchfink/diamond/archive/v$VERSION.tar.gz && tar -zxvf v$VERSION.tar.gz
RUN cd diamond-$VERSION && bash build_simple.sh

ENV PATH="/diamond-$VERSION:${PATH}"

CMD ["diamond"]