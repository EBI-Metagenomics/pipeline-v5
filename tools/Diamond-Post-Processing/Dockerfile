FROM centos:centos7

LABEL maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

COPY diamond_post_run_join.sh /tools/diamond_post_run_join.sh
RUN chmod a+rwx /tools
ENV PATH="/tools"${PATH}"

CMD [diamond_post_run_join.sh]