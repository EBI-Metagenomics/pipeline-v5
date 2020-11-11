FROM alpine:3.7 as build

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             FragGeneScan
# Software Version:     1.31
# Description:          https://github.com/EBI-Metagenomics/fraggenescan
##############################################################
RUN apk add --no-cache build-base git

WORKDIR /

RUN git clone https://github.com/EBI-Metagenomics/fraggenescan.git && \
    cd fraggenescan && make && make clean && make fgs

FROM alpine:3.7

RUN apk add --no-cache bash && \
    mkdir /tools && mkdir /fraggenescan

COPY run_FGS.sh /tools/
COPY --from=build /fraggenescan /fraggenescan

RUN chmod a+x /tools/*

ENV PATH="/fraggenescan:/tools:${PATH}"

CMD ["run_FGS.sh"]