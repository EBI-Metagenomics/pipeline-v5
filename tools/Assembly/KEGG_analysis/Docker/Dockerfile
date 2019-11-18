FROM alpine:3.5

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

# Dependances
RUN apk add --no-cache --update-cache --update python3 && \
apk add --no-cache --update py3-pip && \
apk add --no-cache --update bash && \
pip3 install --upgrade pip && \
pip3 install networkx

# Downloading KEGG help files to generate pathways
RUN mkdir help_files
RUN wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/KEGG/pathways/graphs.pkl -P help_files
RUN wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/KEGG/pathways/all_pathways_names.txt -P help_files
RUN wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/KEGG/pathways/all_pathways_class.txt -P help_files

# Add .py scripts
RUN mkdir /tools
ADD give_pathways.py /tools/give_pathways.py
ADD union_by_contigs.py /tools/union_by_contigs.py
ADD parsing_hmmscan.py /tools/parsing_hmmscan.py
ADD run_pathways.sh /tools/run_pathways.sh

RUN chmod -R a+rwx /tools
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools