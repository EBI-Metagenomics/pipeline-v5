FROM python:3-slim-buster

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             biom convert
# Software Version:     2.1.8
# Description:          Tool to convert mapseq to biom
##############################################################

ENV VERSION=2.1.8

# Python 2.7
# RUN apt-get install -y \
#     python2.7 \
#     python-pip \
#     python-dev

RUN apt update && apt-get install -y build-essential && \ 
    pip install --no-cache-dir numpy h5py cython && \
    pip install --no-cache-dir https://github.com/biocore/biom-format/archive/$VERSION.tar.gz && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /tools/

COPY biom-convert.sh /tools/

RUN chmod -R a+rwx /tools

ENV PATH="/tools:${PATH}"

CMD ["biom-convert.sh"]