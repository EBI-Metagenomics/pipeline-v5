FROM alpine:3.7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             Assign MGY accessions
# Software Version:     1.0
# Description:          Add run to database, assign MGYC
#                       and MGYP scripts
##############################################################
RUN apk add --no-cache bash wget unzip build-base zlib-dev

COPY scripts/* /tools/

RUN chmod a+x /tools/*

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools

