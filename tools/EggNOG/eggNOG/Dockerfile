FROM python:2
FROM centos:centos7

##### Dependances
RUN yum -y update; yum clean all
RUN yum -y install curl wget tar


COPY eggnogmapper /tools/eggnogmapper
COPY emapper.py /tools/emapper.py

RUN wget https://github.com/bbuchfink/diamond/releases/download/v0.9.24/diamond-linux64.tar.gz && tar -xzvf diamond-linux64.tar.gz  && cp diamond /bin/diamond

RUN chmod -R a+rwx /tools
ENV PATH="/tools:${PATH}"

CMD [emapper.py]