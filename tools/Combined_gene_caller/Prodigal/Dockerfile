FROM alpine:3.7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             Prodigal
# Software Version:     2.6.3
# Description:          protein-coding gene prediction for prokaryotic genomes
##############################################################
RUN apk add --no-cache bash git
RUN apk add --no-cache build-base

RUN git clone https://github.com/hyattpd/Prodigal.git
RUN apk add --no-cache zlib-dev
RUN cd Prodigal && make install

ENV PATH="/Prodigal:${PATH}"

CMD ["prodigal"]