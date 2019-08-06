FROM ubuntu:18.04

LABEL maintainer="Varsha Kale <vkale@ebi.ac.uk>"

RUN apt-get update && apt-get install -y \
  wget

ENV ZIP=mapseq-1.2.3-linux.tar.gz
ENV URL=https://github.com/jfmrod/MAPseq/releases/download/v1.2.3/

WORKDIR /mapseq
RUN wget $URL/$ZIP  \
  && tar xvzf $ZIP \
  && rm $ZIP

#ENTRYPOINT ["mapseq-1.2.3-linux/mapseq"]
