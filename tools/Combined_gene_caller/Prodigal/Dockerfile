FROM alpine:3.7 as build

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             Prodigal
# Software Version:     2.6.3
# Description:          protein-coding gene prediction for prokaryotic genomes
##############################################################

RUN apk add --no-cache git build-base zlib-dev

RUN git clone --depth 1 --branch 'v2.6.3' https://github.com/hyattpd/Prodigal.git && \
    cd Prodigal && make install

FROM alpine:3.7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             Prodigal
# Software Version:     2.6.3
# Description:          protein-coding gene prediction for prokaryotic genomes
##############################################################

COPY --from=build /Prodigal /Prodigal

RUN apk add --no-cache bash

ENV PATH="/Prodigal:${PATH}"

CMD ["prodigal"]