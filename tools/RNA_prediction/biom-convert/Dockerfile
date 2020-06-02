FROM ubuntu:18.04

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             biom convert
# Software Version:     2.1.6
# Description:          Tool to convert mapseq to biom
##############################################################

ENV VERSION=2.1.6

# Install dependencies
RUN apt-get update

RUN apt-get install -y software-properties-common
RUN add-apt-repository universe

# Python 2.7
RUN apt-get update && apt-get install -y \
    python2.7 \
    python-pip \
    python-dev

RUN pip install numpy
RUN pip install h5py
RUN pip install biom-format==$VERSION

COPY biom-convert.sh /tools/
RUN chmod -R a+rwx /tools
ENV PATH="/tools:${PATH}"

CMD ["biom-convert.sh"]