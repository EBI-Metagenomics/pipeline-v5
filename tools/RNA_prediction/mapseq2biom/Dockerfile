FROM perl:5.32-slim

COPY mapseq2biom.pl /tools/

RUN chmod a+x /tools/mapseq2biom.pl

ENV PATH="/tools:${PATH}"

##############################################################
# Dockerfile Version:   19.03.1
# Software:             mapseq2biom.pl
# Software Version:     1.0.0
# Description:          Convert mapseq to OTU tsv format for krona
##############################################################

LABEL version=1.0.0

CMD [ "mapseq2biom.pl" ]
