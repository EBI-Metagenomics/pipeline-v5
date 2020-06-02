FROM alpine:3.7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

##############################################################
# Dockerfile Version:   19.03.1
# Software:             HMMER
# Software Version:     3.2.1
# Description:          protein sequence classifier
##############################################################
ENV VERSION=3.2.1

RUN apk add --no-cache bash wget
RUN apk add --no-cache build-base

RUN wget http://eddylab.org/software/hmmer/hmmer-$VERSION.tar.gz \
   && tar -zxvf hmmer-$VERSION.tar.gz \
   && cd hmmer-$VERSION \
   && ./configure && make && make install

ENV PATH="/hmmer-$VERSION:${PATH}"

CMD ["hmmsearch"]

# CMD ["hmmscan"]
