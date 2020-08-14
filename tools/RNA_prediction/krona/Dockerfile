FROM ubuntu:18.04

LABEL maintainer="Varsha Kale <vkale@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             Krona
# Software Version:     2.7.1
# Description:          Tool to visualise Krona charts
##############################################################

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV VERSION=2.7.1

ENV TAR=KronaTools-$VERSION.tar

ENV URL=https://github.com/marbl/Krona/releases/download/v$VERSION/$TAR

WORKDIR /krona

RUN curl -L $URL --silent --show-error -o $TAR && \
    tar -xf $TAR && \
    rm $TAR && \
    cd KronaTools-$VERSION && \
    ./install.pl

CMD ["ktImportText"]
