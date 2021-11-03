FROM ubuntu:20.04 as build

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             Prodigal
# Software Version:     2.6.3
# Description:          protein-coding gene prediction for prokaryotic genomes
##############################################################
RUN apt-get update
RUN apt-get install --yes \
  build-essential \
  git && \
  rm -rf /var/lib/apt/lists/*


RUN git clone --depth 1 --branch 'v2.6.3' https://github.com/hyattpd/Prodigal.git && \
    cd Prodigal && make install

ENV PATH="/Prodigal:${PATH}"

CMD ["prodigal"]