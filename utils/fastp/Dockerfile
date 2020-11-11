FROM alpine:3.7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             fastp 0.20.0
# Description:          filter paired-end reads
##############################################################
RUN apk add --no-cache bash build-base zlib-dev
RUN apk add --no-cache git

ENV VERSION=0.20.0

RUN wget https://github.com/OpenGene/fastp/archive/v$VERSION.zip && unzip v$VERSION.zip && rm v$VERSION.zip && cd fastp-$VERSION && make && make install

CMD ["fastp"]