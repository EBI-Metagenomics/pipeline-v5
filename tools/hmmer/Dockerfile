FROM alpine:3.7 as build

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

##############################################################
# Dockerfile Version:   19.03.1
# Software:             HMMER
# Software Version:     3.2.1
# Description:          protein sequence classifier
##############################################################
ENV VERSION=3.2.1

RUN apk add --no-cache wget build-base

RUN mkdir /hmmer-bin && \ 
   wget -q http://eddylab.org/software/hmmer/hmmer-$VERSION.tar.gz && \
   tar -zxf hmmer-$VERSION.tar.gz && \
   cd hmmer-$VERSION && \
   ./configure --prefix=/hmmer-bin && make && make install

FROM alpine:3.7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

##############################################################
# Dockerfile Version:   19.03.1
# Software:             HMMER
# Software Version:     3.2.1
# Description:          protein sequence classifier
##############################################################
ENV VERSION=3.2.1

RUN apk add --no-cache bash && mkdir /hmmer-bin

COPY --from=build /hmmer-bin /hmmer-bin

ENV PATH="/hmmer-bin/bin:${PATH}"

CMD ["hmmsearch"]