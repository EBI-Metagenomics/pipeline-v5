FROM ubuntu:20.04

# Install compiler and perl stuff
RUN apt-get update && \
  apt-get install --yes \
  build-essential \
  gcc-multilib \
  perl \
  git \
  cpanminus && \
  rm -rf /var/lib/apt/lists/*

# Download code
RUN git clone --branch "v2.0.1" --depth 1 https://github.com/ebi-pf-team/genome-properties.git

RUN cpanm \
  Data::Printer \
  File::Slurp \
  JSON \
  LWP::UserAgent \
  Devel::Camelcadedb \
  strict \
  Clone

ENV PERL5LIB=/genome-properties/code/modules

RUN export PERL5LIB=$PERL5LIB:/genome-properties/code/modules

ENV PATH="/genome-properties/code/scripts/:${PATH}"

CMD ["assign_genome_properties.pl”]