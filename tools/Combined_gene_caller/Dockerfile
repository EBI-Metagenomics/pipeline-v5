# FragGeneScan
FROM quay.io/biocontainers/fraggenescan:1.31--h14c3975_1 AS builder

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

FROM centos:centos7

RUN yum -y update; yum clean all
RUN yum -y install gcc git make wget clang pip python2.7 python2.7-dev; yum clean all

COPY --from=builder /usr/local/bin/FragGeneScan /
COPY --from=builder /usr/local/bin/train /train


# Prodigal
RUN git clone https://github.com/hyattpd/Prodigal.git && cd Prodigal \
&& sed -i -e "s|INSTALLDIR  = /usr/local/bin/|INSTALLDIR  = .|" Makefile && make install && cd ..


# faselector
COPY faselector /bin/
RUN chmod a+x /bin/faselector


# Combined Gene Caller
COPY combined_gene_caller.py /


CMD ["/usr/bin/python2.7 /combined_gene_caller.py"]
