FROM python:2
FROM centos:centos7

##### Dependances
RUN yum -y update; yum clean all
RUN yum -y install curl wget tar

ADD emapper.py .
ADD eggnogmapper .

COPY eggnogmapper /eggnogmapper
COPY emapper.py /emapper.py

RUN wget https://github.com/bbuchfink/diamond/releases/download/v0.9.24/diamond-linux64.tar.gz && tar -xzvf diamond-linux64.tar.gz  && cp diamond /bin/diamond

CMD ["python", "/emapper.py"]