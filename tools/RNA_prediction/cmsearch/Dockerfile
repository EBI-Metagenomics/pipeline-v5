FROM alpine:3.7 as build

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
########################################################################
# Dockerfile Version:   19.03.1
# Software:             Infernal (cmsearch)
# Software Version:     1.1.2
# Description:          Infernal ("INFERence of RNA ALignment")
#                       is for searching DNA sequence databases
#                       for RNA structure and sequence similarities.
########################################################################

RUN apk add --no-cache wget build-base

ENV VERSION=1.1.2

RUN wget -q http://eddylab.org/infernal/infernal-$VERSION.tar.gz -q && \
    tar xf infernal-$VERSION.tar.gz && \
    rm infernal-$VERSION.tar.gz

RUN cd infernal-$VERSION && ./configure && make

FROM alpine:3.7

RUN apk add --no-cache bash && mkdir /infernal-1.1.2

COPY --from=build /infernal-1.1.2/src /infernal-1.1.2

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/infernal-1.1.2

CMD ["cmsearch"]