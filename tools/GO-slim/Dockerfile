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

# Java
RUN apt-get install -y openjdk-8-jre

RUN pip install psutil

COPY go-basic-metagenomics_release_20160705.obo /tools/go-basic-metagenomics_release_20160705.obo
COPY metagenomics_go_slim_banding.txt /tools/metagenomics_go_slim_banding.txt
COPY metagenomics_go_slim_ids.txt /tools/metagenomics_go_slim_ids.txt
COPY owltools/* /tools/owltools/
COPY go_summary-config.json go_summary-config.json
RUN chmod -R a+rwx /tools/owltools

COPY go_summary_pipeline-1.0.py /tools/go_summary_pipeline-1.0.py
RUN chmod -R a+rwx /tools
ENV PATH="/tools:${PATH}"

CMD ["go_summary_pipeline-1.0.py"]