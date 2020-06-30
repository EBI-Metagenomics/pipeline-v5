FROM ubuntu:18.04
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libimage-magick-perl

##############################################################
# Dockerfile Version:   19.03.1
# Software:             esl-ssplit.pl
# Software Version:     1.0.0
# Description:          Chunking DNA files
##############################################################

RUN mkdir /tools
COPY esl-ssplit.pl /tools

RUN chmod -R a+rwx /tools
ENV PATH="/tools:${PATH}"

RUN apt-get install -y curl unzip autoconf

RUN mkdir -p src && cd src && curl -k -L -o easel-Bio-Easel-0.12.zip https://github.com/EddyRivasLab/easel/archive/Bio-Easel-0.12.zip
RUN cd src && unzip easel-Bio-Easel-0.12.zip && mv easel-Bio-Easel-0.12 easel && rm easel-Bio-Easel-0.12.zip && cd ..

RUN cpan install Inline
RUN cpan install File::ShareDir  #::Install

RUN cpan install Inline::C

#RUN cd src/easel && autoconf && ./configure && make
CMD ["esl-ssplit.pl"]