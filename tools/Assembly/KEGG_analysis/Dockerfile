FROM python:3
FROM centos:centos7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"


##### Dependances
RUN yum -y update; yum clean all
RUN yum -y install curl wget fetch perl bzip2 make; yum clean all


##### GNU parallel
RUN (wget -O - pi.dk/3 || curl pi.dk/3/ || fetch -o - pi.dk/3) | bash
RUN echo 'will cite' | parallel --citation &> /dev/null || true


##### Python packages
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"; python get-pip.py
RUN pip install networkx numpy pandas biopython


##### KEGG pathways downloading
RUN mkdir pathways

# downloading list of names of pathways
RUN curl -s http://rest.kegg.jp/list/module | cut -f1 | cut -c 4- > pathways/list_pathways.txt

# taking DEFINITION file with pathway from KEGG file
# saving in format: <name:pathway>
RUN parallel -k echo -n '{}:' ';' curl -s http://rest.kegg.jp/get/{} '|' grep ^DEFINITION '|' cut -c 13- :::: pathways/list_pathways.txt > pathways/all_pathways.txt
# taking NAME
RUN parallel -k echo -n '{}:' ';' curl -s http://rest.kegg.jp/get/{} '|' grep ^NAME '|' cut -c 13- :::: pathways/list_pathways.txt > pathways/all_pathways_names.txt
# taking CLASS
RUN parallel -k echo -n '{}:' ';' curl -s http://rest.kegg.jp/get/{} '|' grep ^CLASS '|' cut -c 13- :::: pathways/list_pathways.txt > pathways/all_pathways_class.txt


##### Create a Graph for each pathway
ADD KEGG_pathways/make_graphs.py .
RUN python make_graphs.py -i pathways/all_pathways.txt


# Add .py scripts
mkdir /tools
COPY KEGG_pathways/give_pathways.py /tools/give_pathways.py
COPY Union_by_contigs/union_by_contigs.py /tools/union_by_contigs.py
COPY Parsing_hmmscan/parsing_hmmscan.py /tools/parsing_hmmscan.py

RUN chmod -R a+rwx /tools
ENV PATH="/tools:${PATH}"


CMD [give_pathways.py]