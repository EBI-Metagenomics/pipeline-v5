FROM ubuntu:16.04

# Install prerequisites
RUN apt update -qq && \
    apt-get -qq install -y r-base python3 python3-pip bats wget

# Python dependencies
RUN pip3 install -q bucket-command-wrapper==0.3.0

# R dependencies
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile && \
    Rscript -e "install.packages('Rcpp'); source('https://bioconductor.org/biocLite.R'); biocLite('qvalue'); install.packages('glmnet')"

RUN mkdir /scratch

RUN mkdir /usr/local/virfinder
RUN wget https://github.com/FredHutch/docker-virfinder/raw/master/data/VirFinder_1.1.tar.gz
RUN mv /VirFinder_1.1.tar.gz /usr/local/virfinder/ && tar -zxvf /usr/local/virfinder/VirFinder_1.1.tar.gz --directory /usr/local/virfinder/

RUN R CMD INSTALL /usr/local/virfinder/VirFinder

ADD /run_virfinder.Rscript /usr/local/bin/

