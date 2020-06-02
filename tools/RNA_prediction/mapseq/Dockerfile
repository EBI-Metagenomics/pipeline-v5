FROM alpine:3.7

LABEL maintainer="Varsha Kale <vkale@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             MAPseq
# Software Version:     1.2.3
# Description:          Image for MAPseq tool
##############################################################
RUN apk add --no-cache bash wget

# RUN apk add --no-cache build-base
# RUN apt-get update && apt-get install -y wget

ENV VERSION=1.2.3

ENV ZIP=mapseq-$VERSION-linux.tar.gz
ENV URL=https://github.com/jfmrod/MAPseq/releases/download/v$VERSION/

WORKDIR /mapseq/
RUN wget $URL/$ZIP  \
  && tar xvzf $ZIP \
  && rm $ZIP

ENV PATH="/mapseq/mapseq-$VERSION-linux/:${PATH}"

CMD ["mapseq"]
