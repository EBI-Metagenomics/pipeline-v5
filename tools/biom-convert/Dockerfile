FROM ubuntu:18.04

# Install dependencies
RUN apt-get update

RUN apt-get install -y software-properties-common
RUN add-apt-repository universe

# Python 2.7
RUN apt-get update && apt-get install -y \
    python2.7 \
    python-pip \
    python-dev

RUN pip install numpy
RUN pip install biom-format
RUN pip install h5py

COPY test-mapseq.tsv /test-mapseq.tsv
COPY test.txt /test.txt

CMD ["biom", "convert"]