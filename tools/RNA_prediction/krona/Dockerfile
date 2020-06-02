FROM ubuntu:18.04

LABEL maintainer="Varsha Kale <vkale@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             Krona
# Software Version:     2.7.1
# Description:          Tool to visualise Krona charts
##############################################################
RUN apt-get update && apt-get install -y wget

ENV VERSION=2.7.1

ENV ZIP=KronaTools-$VERSION.tar
ENV URL=https://github.com/marbl/Krona/releases/download/v$VERSION/

WORKDIR /krona
RUN wget $URL/$ZIP  \
  && tar xvf $ZIP \
  && rm $ZIP \
  && cd KronaTools-$VERSION \
  && ./install.pl

CMD ["ktImportText"]
