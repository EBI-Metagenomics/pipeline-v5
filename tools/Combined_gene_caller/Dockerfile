FROM centos:centos7

RUN yum -y update; yum clean all
RUN yum -y install gcc git make wget clang pip python2.7 python2.7-dev; yum clean all

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
##############################################################
# Dockerfile Version:   19.03.1
# Software:             post-processing

##############################################################

# faselector
COPY faselector /tools/

COPY unite_protein_predictions.py /tools/

RUN chmod -R a+rwx /tools
ENV PATH="/tools:${PATH}"

CMD ["unite_protein_predictions.py"]