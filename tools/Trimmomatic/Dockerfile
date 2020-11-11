FROM ubuntu:20.04

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
########################################################################
# Dockerfile Version:   19.03.1
# Software:             Trimmomatic
# Software Version:     0.36
# Description:          trimming fastq
########################################################################

ENV VERSION=0.36

RUN apt-get update && apt-get -y install openjdk-8-jre unzip && \
    rm -rf /var/lib/apt/lists/*

ADD http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-$VERSION.zip /NGStools/

RUN unzip /NGStools/Trimmomatic-$VERSION.zip && \
    mkdir /tools && \
    mv Trimmomatic-$VERSION/trimmomatic-$VERSION.jar /tools/trimmomatic.jar

COPY trimmomatic /tools/

RUN chmod a+rwx /tools/trimmomatic

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools

CMD ["trimmomatic"]