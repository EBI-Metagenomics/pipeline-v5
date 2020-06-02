FROM ubuntu:18.04

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN apt-get update
RUN apt-get install -y wget apt-utils gnupg
RUN mkdir /tools

# setup_antismash_repository
RUN apt-get update && apt-get install -y apt-transport-https
RUN wget http://dl.secondarymetabolites.org/antismash-stretch.list -O /etc/apt/sources.list.d/antismash.list
RUN wget -q -O- http://dl.secondarymetabolites.org/antismash.asc > secondary_stdout
RUN apt-key add secondary_stdout
RUN apt-get update


ENV DEBIAN_FRONTEND=noninteractive
# Install tzdata, force no interaction
RUN apt-get install -y tzdata

# Set the timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime

# Reconfigure tzdata, no interaction
RUN dpkg-reconfigure --frontend noninteractive tzdata

# install_prerequisites
RUN apt-get install -y \
                         clustalw \
                         curl \
                         default-jre-headless \
                         diamond-aligner \
                         fasttree \
                         glimmerhmm \
                         hmmer2 \
                         hmmer \
                         hmmer2-compat \
                         mafft \
                         meme-suite \
                         muscle \
                         ncbi-blast+ \
                         prodigal \
                         python-backports.lzma \
                         python-bcbio-gff \
                         python-dev \
                         python-ete2 \
                         python-excelerator \
                         python-indigo \
                         python-matplotlib \
                         python-networkx \
                         python-pandas \
                         python-pip \
                         python-pyquery \
                         python-pysvg \
                         python-scipy \
                         python-sklearn \
                         tigr-glimmer
RUN pip install "biopython>=1.72"
RUN pip install helperlibs

# antismash
ENV VERSION=4.2.0
RUN wget https://dl.secondarymetabolites.org/releases/$VERSION/antismash-$VERSION.tar.gz && tar -zxf antismash-$VERSION.tar.gz
RUN apt-get install -y python-pip vim
RUN pip install ./antismash-$VERSION
ENV PATH="/usr/lib/tigr-glimmer:${PATH}"

# install dbs
RUN download-antismash-databases


# pipeline tools
COPY run_antismash_short.sh /tools/

RUN chmod a+rwx /tools/*

ENV PATH="/tools:${PATH}"
#ENV PYTHONPATH="/tools/pip:${PYTHONPATH}"

CMD ["run_antismash_short.sh"]

