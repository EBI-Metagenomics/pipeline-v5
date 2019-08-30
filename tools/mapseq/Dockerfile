FROM ubuntu:18.04

LABEL maintainer="Varsha Kale <vkale@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             MAPseq
# Software Version:     1.2.3
# Description:          Image for MAPseq tool
##############################################################
RUN apt-get update && apt-get install -y \
  wget

ENV ZIP=mapseq-1.2.3-linux.tar.gz
ENV URL=https://github.com/jfmrod/MAPseq/releases/download/v1.2.3/

WORKDIR /mapseq/
RUN wget $URL/$ZIP  \
  && tar xvzf $ZIP \
  && rm $ZIP

ENV PATH="/mapseq/mapseq-1.2.3-linux/:${PATH}"

CMD ["mapseq"]
