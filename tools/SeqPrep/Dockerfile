FROM alpine:3.7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             SeqPrep
# Software Version:     1.2
# Description:          merge paired end Illumina reads
#                       that are overlapping into a single
#                       longer read
##############################################################
RUN apk add --no-cache bash wget unzip build-base zlib-dev

ENV VERSION=1.2

RUN wget https://github.com/jstjohn/SeqPrep/archive/v$VERSION.zip && \
    unzip v$VERSION.zip && \
    cd SeqPrep-$VERSION && make

ENV PATH="/SeqPrep-$VERSION:${PATH}"

CMD ["SeqPrep"]