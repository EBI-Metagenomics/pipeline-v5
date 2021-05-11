# Dockerfile for CRISPRCasFinder

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        build-essential \
        wget \
        unzip \
        curl \
        git \
        default-jre \
        python \
        parallel \
        cpanminus \
        hmmer \
        emboss \
        emboss-lib \
        ncbi-blast+ \
        bioperl \
        bioperl-run \
        libdatetime-perl \
        libxml-simple-perl \
        libdigest-md5-perl \
        muscle \
        prodigal 

# perl deps
RUN cpanm -n Unix::Sysexits
RUN cpanm -n Try::Tiny
RUN cpanm -n Test::Most
RUN cpanm -n JSON::Parse
RUN cpanm -n Class::Struct
RUN cpanm -n Bio::DB::Fasta
RUN cpanm -n File::Copy
RUN cpanm -n Bio::Seq Bio::SeqIO
RUN cpanm -n Bio::Tools::Run::Alignment::Muscle

# get CRISPRCasFinder
ENV crisprcasfinderVer="4.2.20"
WORKDIR /opt
RUN wget -q -O CRISPRCasFinder.zip 'https://crisprcas.i2bc.paris-saclay.fr/Home/DownloadFile?filename=CRISPRCasFinder.zip' && \
    unzip CRISPRCasFinder.zip && \
    mv CRISPRCasFinder-release-${crisprcasfinderVer} CRISPRCasFinder && \
    mkdir CRISPRCasFinder/src CRISPRCasFinder/bin && \
    ln -s /opt/CRISPRCasFinder/CRISPRCasFinder.pl /usr/local/bin/

# build vmatch
ENV vmatchVer="2.3.0"
WORKDIR /opt/CRISPRCasFinder/src
RUN wget -q http://vmatch.de/distributions/vmatch-${vmatchVer}-Linux_x86_64-64bit.tar.gz && \
    tar -zxf vmatch-${vmatchVer}-Linux_x86_64-64bit.tar.gz && \
    gcc -Wall -Werror -fPIC -O3 -shared vmatch-${vmatchVer}-Linux_x86_64-64bit/SELECT/sel392.c -o /opt/CRISPRCasFinder/sel392v2.so && \
    cp vmatch-${vmatchVer}-Linux_x86_64-64bit/vmatch /usr/local/bin/vmatch2 && \
    cp vmatch-${vmatchVer}-Linux_x86_64-64bit/mkvtree /usr/local/bin/mkvtree2 && \
    cp vmatch-${vmatchVer}-Linux_x86_64-64bit/vsubseqselect /usr/local/bin/vsubseqselect2 && \
    rm -rf vmatch-${vmatchVer}-Linux_x86_64-64bit*

# get MacSyFinder
ENV macsyfinderVer="1.0.5"
WORKDIR /opt
RUN wget -q https://dl.bintray.com/gem-pasteur/MacSyFinder/macsyfinder-${macsyfinderVer}.tar.gz && \
    tar -xzf macsyfinder-${macsyfinderVer}.tar.gz && \
    rm macsyfinder-${macsyfinderVer}.tar.gz && \
    ln -s /opt/macsyfinder-1.0.5/bin/macsyfinder /usr/local/bin/
ENV MACSY_HOME=/opt/macsyfinder-1.0.5/

# add scripts to format output
WORKDIR /usr/local/bin
COPY crisprcf2fasta.py /usr/local/bin/
COPY crisprcf2gff.py /usr/local/bin/
RUN chmod +x /usr/local/bin/*

LABEL software="CRISPRCasFinder"
LABEL software.version="4.2.21"
LABEL description="CRISPRCasFinder is an updated, improved, and integrated version of CRISPRFinder and CasFinder."
LABEL website="https://github.com/dcouvin/CRISPRCasFinder/"
LABEL license="https://github.com/dcouvin/CRISPRCasFinder/blob/master/COPYRIGHT"

# for singularity compatibility
ENV LC_ALL=C

RUN mkdir /data
WORKDIR /data

CMD ["/bin/bash", "-c"]