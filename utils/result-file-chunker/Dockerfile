FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y genometools && \
    rm -rf /var/lib/apt/lists/*

COPY split_fasta_by_size.sh /tools/

RUN chmod a+x /tools/*

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools

CMD [ "split_fasta_by_size.sh" ]