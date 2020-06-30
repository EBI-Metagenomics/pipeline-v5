#!/bin/bash

function display_help {
    echo "$0 [options]"
    echo ""
    echo "--base, -b URL    Use URL as base URL for antiSMASH tarball"
    echo "--help, -h        Display this help"
}

while true; do
    case "$1" in
        -h|--help) display_help; exit 0;;
        -b|--base) ANTISMASH_ALTERNATIVE_BASE=$2; shift; shift ;;
        "") break;;
        *) display_help; exit 1;;
    esac
done

# Set up some constants
ANTISMASH_VERSION="4.2.0"
ANTISMASH_BASE="https://bitbucket.org/antismash/antismash/downloads"
if [ x$ANTISMASH_ALTERNATIVE_BASE != x ]; then
    ANTISMASH_URL=$ANTISMASH_ALTERNATIVE_BASE/antismash-${ANTISMASH_VERSION}.tar.gz
else
    ANTISMASH_URL=$ANTISMASH_BASE/antismash-${ANTISMASH_VERSION}.tar.gz
fi

# Utility functions
function die {
    cat <<< "$@" 1>&2
    exit 1
}

function setup_antismash_repository {
    apt-get update && apt-get install -y apt-transport-https || die "Failed to install https transport layer"
    wget http://dl.secondarymetabolites.org/antismash-stretch.list -O /etc/apt/sources.list.d/antismash.list || die "Failed to download antismash repository setup"
    wget -q -O- http://dl.secondarymetabolites.org/antismash.asc | apt-key add - || die "Failed to add apt key"
    apt-get update || die "Failed to update antiSMASH package sources"
}

function install_prerequisites {
     apt-get install -y \
                         clustalw \
                         curl \
                         default-jre-headless \
                         diamond-aligner \
                         fasttree \
                         glimmerhmm \
                         hmmer2 \
                         hmmer \
                         hmmer2-compat \
                         mafft \
                         meme-suite \
                         muscle \
                         ncbi-blast+ \
                         prodigal \
                         python-backports.lzma \
                         python-bcbio-gff \
                         python-dev \
                         python-ete2 \
                         python-excelerator \
                         python-indigo \
                         python-matplotlib \
                         python-networkx \
                         python-pandas \
                         python-pip \
                         python-pyquery \
                         python-pysvg \
                         python-scipy \
                         python-sklearn \
                         tigr-glimmer \
        || die "Failed to install antiSMASH prerequisites"
    pip install --user "biopython>=1.72" || die "Failed to install antiSMASH prerequisites"
    pip install --user helperlibs || die "Failed to install antiSMASH prerequisites"
}

function install_antismash {
    wget $ANTISMASH_URL || die "Failed to download $ANTISMASH_URL"
    tar xf antismash-${ANTISMASH_VERSION}.tar.gz || die "Failed to extract antiSMASH"
    pushd antismash-${ANTISMASH_VERSION} 2>/dev/null
    echo "Downloading databases. This will take a while."
    python download_databases.py || die "Failed to download databases"
    popd 2>/dev/null

    cat > ${HOME}/.antismash.cfg <<EOF
[glimmer]
basedir = /usr/lib/tigr-glimmer
EOF

    if [ ! -d ${HOME}/bin ]; then
        mkdir ${HOME}/bin
    fi
    ln -s $(pwd)/antismash-${ANTISMASH_VERSION}/run_antismash.py ${HOME}/bin/run_antismash.py
}


### Run the install

setup_antismash_repository
install_prerequisites
install_antismash
