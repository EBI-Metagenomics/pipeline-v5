FROM ubuntu:14.04

# Update the repository sources list
RUN apt-get update

# Install compiler and perl stuff
RUN apt-get install --yes \
  build-essential \
  gcc-multilib \
  perl \
  git

# Download code
RUN git clone https://github.com/ebi-pf-team/genome-properties.git

# Install perl modules
RUN apt-get install --yes cpanminus

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