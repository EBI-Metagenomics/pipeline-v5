FROM alpine:3.7

LABEL Maintainer="Ekaterina Sakharova <kates@ebi.ac.uk>"
RUN apk add --no-cache bash

COPY empty_tax.sh /tools/
RUN chmod a+rwx /tools/empty_tax.sh

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools

CMD ["empty_tax.sh"]

