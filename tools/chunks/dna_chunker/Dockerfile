##############################################################
# Dockerfile Version:   19.03.1
# Software:             esl-ssplit.pl
# Software Version:     1.0.0
# Description:          Chunking DNA files
##############################################################

FROM alpine:3.12.0

RUN apk add --no-cache build-base autoconf curl perl perl-dev bash

RUN mkdir -p /opt

WORKDIR /opt

# easl
RUN mkdir src && cd src && \
    curl -L -o easel-Bio-Easel-0.12.tar.gz https://github.com/EddyRivasLab/easel/archive/Bio-Easel-0.12.tar.gz && \
    tar -xzf easel-Bio-Easel-0.12.tar.gz && \
    mv easel-Bio-Easel-0.12 easel && \
    rm easel-Bio-Easel-0.12.tar.gz

RUN cpan install -T Inline Inline::C

RUN curl -L -o bio-easel.tar.gz https://github.com/nawrockie/Bio-Easel/archive/vadr-1.1.tar.gz && \
    tar -xzf bio-easel.tar.gz && \
    mv Bio-Easel-vadr-1.1/* . && \
    chmod +x scripts/esl-ssplit.pl

RUN perl Makefile.PL && make && make test && make install && \
    mkdir /tools/

COPY esl-ssplit.sh /tools/

RUN chmod +x /tools/*

ENV PATH="/opt/scripts/:/tools/:${PATH}"

CMD [ "esl-ssplit.sh" ]