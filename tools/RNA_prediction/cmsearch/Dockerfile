FROM alpine:3.7

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
########################################################################
# Dockerfile Version:   19.03.1
# Software:             Infernal (cmsearch)
# Software Version:     1.1.2
# Description:          Infernal ("INFERence of RNA ALignment")
#                       is for searching DNA sequence databases
#                       for RNA structure and sequence similarities.
########################################################################

RUN apk add --no-cache bash wget
RUN apk add --no-cache build-base

ENV VERSION=1.1.2

RUN wget http://eddylab.org/infernal/infernal-$VERSION.tar.gz
RUN tar xvf infernal-$VERSION.tar.gz && rm infernal-$VERSION.tar.gz
RUN cd infernal-$VERSION && ./configure
RUN cd infernal-$VERSION && make

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/infernal-1.1.2/src

CMD ["cmsearch"]