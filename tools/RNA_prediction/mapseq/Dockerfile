FROM alpine:3.7

LABEL maintainer="Varsha Kale <vkale@ebi.ac.uk>"

##############################################################
# Dockerfile Version:   19.03.1
# Software:             MAPseq
# Software Version:     1.2.3
# Description:          Image for MAPseq tool
##############################################################

ENV VERSION=1.2.3

RUN apk add --no-cache bash wget

ENV ZIP=mapseq-$VERSION-linux.tar.gz

ENV URL=https://github.com/jfmrod/MAPseq/releases/download/v$VERSION/

WORKDIR /mapseq/

# Remove mapseq default DB,
# it has to be provided in the CWL description

RUN wget -q $URL/$ZIP && \
    tar -xzf $ZIP && \
    rm -rf mapseq-$VERSION-linux/share/ \
    rm $ZIP

ENV PATH="/mapseq/mapseq-$VERSION-linux/:${PATH}"

CMD ["mapseq"]
