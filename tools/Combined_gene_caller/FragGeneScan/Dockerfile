FROM debian:stable-slim

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             FragGeneScan
# Software Version:     1.31
# Description:          https://github.com/EBI-Metagenomics/fraggenescan
##############################################################
RUN apt-get update -qq
RUN apt-get install -y -qq gcc make git

RUN git clone https://github.com/EBI-Metagenomics/fraggenescan.git
RUN cd fraggenescan && make && make clean && make fgs

ENV PATH="/fraggenescan:${PATH}"

COPY run_FGS.sh /tools/
RUN chmod a+x /tools/*
ENV PATH="/tools:${PATH}"

CMD ['run_FGS.sh']

