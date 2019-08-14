FROM python:2.7.10

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN pip install -q biopython

COPY MGRAST_base.py /MGRAST_base.py

RUN chmod a+rwx /MGRAST_base.py
CMD ["python", "/MGRAST_base.py"]