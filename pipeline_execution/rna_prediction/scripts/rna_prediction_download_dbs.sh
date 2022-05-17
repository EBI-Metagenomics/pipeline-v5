#!/bin/bash

set -e

usage() {
    echo ""
    echo "Download the rna_prediction workflow reference databases from the EBI FTP server"
    echo "* requires 'wget"
    echo ""
    echo "-f Output folder [mandatory]"
    echo " "
}

OUTPUT=""

while getopts "f:h" opt; do
    case $opt in
    f)
        OUTPUT="$OPTARG"
        if [ -z "$OUTPUT" ]; then
            echo ""
            echo "ERROR -f cannot be empty." >&2
            usage
            exit 1
        fi
        ;;
    h)
        usage
        exit 0
        ;;
    :)
        usage
        exit 1
        ;;
    \?)
        echo ""
        echo "Invalid option -${OPTARG}" >&2
        usage
        exit 1
        ;;
    esac
done

if ((OPTIND == 1)); then
    echo ""
    echo "ERROR: No options specified"
    usage
    exit 1
fi

CWD=$(pwd)

echo "${CWD}"

mkdir -p "${OUTPUT}" && cd "${OUTPUT}" || exit 1

echo "Downloading silva_ssu and silva_lsu"

# download silva dbs #
mkdir silva_ssu silva_lsu

wget \
    ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/silva_ssu-20200130.tar.gz \
    ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/silva_lsu-20200130.tar.gz
tar xfv silva_ssu-20200130.tar.gz --directory=silva_ssu --strip-components 1
tar xfv silva_lsu-20200130.tar.gz --directory=silva_lsu --strip-components 1

echo "Downloading the rfam_models"

mkdir ribosomal

wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rfam_models/ribosomal_models/RF*.cm \
    ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rfam_models/ribosomal_models/ribo.claninfo \
    -P ribosomal

# rRNA.claninfo
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rRNA.claninfo

# other Rfam models
mkdir other

wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rfam_models/other_models/*.cm \
    -P other

cd "${CWD}"

echo "Done."
