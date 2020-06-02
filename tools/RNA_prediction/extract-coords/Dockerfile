FROM alpine:3.7

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"

RUN apk add --no-cache bash

COPY awk_tool /tools/
RUN chmod a+rwx /tools/awk_tool

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools

CMD ["awk_tool"]