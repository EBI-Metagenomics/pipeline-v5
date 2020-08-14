FROM busybox AS buildcore

LABEL Maintainer="MGnify team <https://www.ebi.ac.uk/support/metagenomics>"

ARG IPR=5
ENV IPR $IPR
ARG IPRSCAN=5.36-75.0
ENV IPRSCAN $IPRSCAN

RUN mkdir -p /opt

RUN wget -q -O /opt/interproscan-core-$IPRSCAN.tar.gz ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/alt/interproscan-core-$IPRSCAN.tar.gz
RUN wget -q -O /opt/interproscan-core-$IPRSCAN.tar.gz.md5 ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/alt/interproscan-core-$IPRSCAN.tar.gz.md5

WORKDIR /opt

RUN md5sum -c interproscan-core-$IPRSCAN.tar.gz.md5

RUN mkdir -p /opt/interproscan

RUN tar -pxzf interproscan-core-$IPRSCAN.tar.gz \
    -C /opt/interproscan --strip-components=1 && \
    rm -f interproscan-core-$IPRSCAN.tar.gz interproscan-core-$IPRSCAN.tar.gz.md5

FROM busybox AS buildbin

ARG IPR=5
ENV IPR $IPR
ARG IPRSCAN=5.36-75.0
ENV IPRSCAN $IPRSCAN

RUN mkdir -p /opt

RUN wget -q -O /opt/interproscan-mgbin-$IPRSCAN.tar.gz ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/alt/interproscan-mgbin-$IPRSCAN.tar.gz
RUN wget -q -O /opt/interproscan-mgbin-$IPRSCAN.tar.gz.md5 ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/alt/interproscan-mgbin-$IPRSCAN.tar.gz.md5

WORKDIR /opt

RUN md5sum -c interproscan-mgbin-$IPRSCAN.tar.gz.md5

RUN mkdir -p /opt/interproscan

RUN tar -pxvzf interproscan-mgbin-$IPRSCAN.tar.gz \
    -C /opt/interproscan --strip-components=1 && \
    rm -f interproscan-mgbin-$IPRSCAN.tar.gz interproscan-mgbin-$IPRSCAN.tar.gz.md5

FROM biocontainers/biocontainers:latest

USER root

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -f --reinstall -y python3 && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER biodocker

COPY --from=buildcore /opt/interproscan /opt/interproscan
COPY --from=buildbin /opt/interproscan/bin /opt/interproscan/bin

ENV PATH="/opt/interproscan/:/opt/interproscan/bin:${PATH}"

CMD ["/bin/bash", "/opt/interproscan/interproscan.sh"]