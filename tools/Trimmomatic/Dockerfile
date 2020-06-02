FROM ubuntu:18.04

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
########################################################################
# Dockerfile Version:   19.03.1
# Software:             Trimmomatic
# Software Version:     0.36
# Description:          trimming fastq
########################################################################

ENV VERSION=0.36

RUN apt-get update && apt-get -y install \
    openjdk-8-jre \
	python3 \
    unzip

ADD http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-$VERSION.zip /NGStools/

RUN unzip /NGStools/Trimmomatic-$VERSION.zip

RUN mkdir /tools
RUN mv Trimmomatic-$VERSION/trimmomatic-$VERSION.jar /tools/trimmomatic.jar
COPY trimmomatic /tools/

RUN apt-get install -y nodejs
RUN chmod a+rwx /tools/trimmomatic

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools

CMD ["trimmomatic"]