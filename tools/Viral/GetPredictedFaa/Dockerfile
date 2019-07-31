FROM python:2.7.10

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN pip install -q biopython
##############################################################
# Dockerfile Version:   18.06.0-ce
# Software:             get_predicted_faa.py
# Software Version:     1.0.0
# Description:          Script generates predicted_annotated_CDS.faa
##############################################################
COPY . /

CMD ["python", "/get_predicted_faa.py"]
