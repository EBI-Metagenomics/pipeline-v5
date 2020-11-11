FROM alpine:3.7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             seqtk + bash wrapper
# Software Version:     1.3 (r106)
# Description:          filter reads < LEN bp from fastq
#                       paired-end files
##############################################################
RUN apk add --no-cache bash wget gzip build-base zlib-dev

# install seqtk
ENV VERSION=1.3
RUN wget https://github.com/lh3/seqtk/archive/v$VERSION.zip && \
    unzip v$VERSION.zip && \
    cd seqtk-$VERSION && make

# add wrapper
COPY filter_paired_reads.sh /tools/
RUN chmod a+x /tools/*

ENV PATH="/seqtk-$VERSION:/tools:${PATH}"

CMD ["filter_paired_reads.sh"]