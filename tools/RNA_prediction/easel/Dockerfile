FROM alpine:3.7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             Easel
# Software Version:     0.45h
# Description:          https://github.com/EddyRivasLab/easel
##############################################################
RUN apk add --no-cache bash wget
RUN apk add --no-cache build-base
RUN apk add --no-cache autoconf automake

ENV VERSION=0.45h
ENV ZIP=easel-$VERSION.tar.gz

RUN wget https://github.com/EddyRivasLab/easel/archive/$ZIP && tar xvzf $ZIP && rm $ZIP
RUN cd easel-easel-$VERSION && chmod a+x * && autoconf && ./configure && make

ENV PATH="/easel-easel-$VERSION/miniapps:${PATH}"

RUN mkdir /tools
COPY esl-index.sh /tools/esl-index.sh
RUN chmod -R a+rwx /tools
ENV PATH="/tools:${PATH}"

CMD [ "esl-index.sh" ]