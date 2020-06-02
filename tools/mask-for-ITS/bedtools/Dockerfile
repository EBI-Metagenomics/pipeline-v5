FROM alpine:3.7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##########################################################################
# Dockerfile Version:   19.03.1
# Software:             bedtools
# Software Version:     2.28.0
# Description:          bedtools
##########################################################################
RUN apk add --no-cache bash wget
RUN apk add --no-cache build-base
RUN apk add --no-cache zlib-dev bzip2-dev xz-dev python

ENV VERSION=2.28.0

ENV ZIP=bedtools-$VERSION.tar.gz

RUN wget https://github.com/arq5x/bedtools2/releases/download/v$VERSION/bedtools-$VERSION.tar.gz  \
  && tar xvzf $ZIP \
  && rm $ZIP
RUN cd bedtools2 && make

ENV PATH="/bedtools2/bin:${PATH}"

CMD ["bedtools", "maskfasta"]


