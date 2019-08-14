FROM python:2
FROM centos:centos7

ADD download_eggnog_data.py .
ADD eggnogmapper/ .

COPY download_eggnog_data.py /download_eggnog_data.py
COPY eggnogmapper /eggnogmapper

CMD ["python", "/download_eggnog_data.py"]