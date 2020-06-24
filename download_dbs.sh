#!/bin/bash

# ====== versions
DIAMOND_VERSION=0.9.25
UNIREF90_VERSION=v2019_08
IPR=5
IPRSCAN=5.36-75.0
MOTUS_VERSION=2.5.1
SILVA_VERSION=20200130
AMPLICON_DB_VERSION=20200214

export FTP_DBS=ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/


while getopts :m:a:w: option; do
	case "${option}" in
		m) AMPLICON_PIPELINE=${OPTARG};;
		a) ASSEMBLY_PIPELINE=${OPTARG};;
		w) WGS_PIPELINE=${OPTARG};;
	esac
done

# ====== download

# SILVA
wget \
  ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/silva_ssu-$SILVA_VERSION.tar.gz \
  ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/silva_lsu-$SILVA_VERSION.tar.gz
tar -pxvzf silva_ssu-$SILVA_VERSION.tar.gz && mkdir silva_ssu && mv silva_ssu-$SILVA_VERSION/* silva_ssu/
tar -pxvzf silva_lsu-$SILVA_VERSION.tar.gz && mkdir silva_lsu && mv silva_lsu-$SILVA_VERSION/* silva_lsu
rm silva_ssu-$SILVA_VERSION.tar.gz silva_lsu-$SILVA_VERSION.tar.gz
rm -rf silva_ssu-$SILVA_VERSION silva_lsu-$SILVA_VERSION

# download Pfam ribosomal models
mkdir ribosomal
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rfam_models/ribosomal_models/RF*.cm \
  -P ribosomal

# ----------------- AMPLICON -----------------
if [ "${AMPLICON_PIPELINE}" == "True" ]; then
    mkdir UNITE
    wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/UNITE-$AMPLICON_DB_VERSION.tar.gz
    tar -xvzf UNITE-$AMPLICON_DB_VERSION.tar.gz && rm UNITE-$AMPLICON_DB_VERSION.tar.gz
    mv UNITE-$AMPLICON_DB_VERSION/* UNITE && rm -rf UNITE-$AMPLICON_DB_VERSION

    mkdir ITSoneDB
    wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/ITSoneDB-$AMPLICON_DB_VERSION.tar.gz
    tar -xvzf ITSoneDB-$AMPLICON_DB_VERSION.tar.gz && rm ITSoneDB-$AMPLICON_DB_VERSION.tar.gz
    mv ITSoneDB-$AMPLICON_DB_VERSION/* ITSoneDB && rm -rf ITSoneDB-$AMPLICON_DB_VERSION

    wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rfam_models/ribosomal_models/ribo.claninfo \
  -P ribosomal
fi

if [ "${AMPLICON_PIPELINE}" == "False" ]; then
    # IPS
    wget ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/$IPR/$IPRSCAN/alt/interproscan-data-$IPRSCAN.tar.gz && \
         tar -pxvzf interproscan-data-$IPRSCAN.tar.gz && \
         rm -f interproscan-data-$IPRSCAN.tar.gz
    # rRNA.claninfo
    wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rRNA.claninfo
    # other Rfam models
    mkdir other
    wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rfam_models/other_models/*.cm \
     -P other
    # kofam db
    wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/db_kofam.hmm.h3?.gz
    gunzip db_kofam.hmm.h3?.gz
    mkdir db_kofam && mv db_kofam.hmm.h3? db_kofam
fi

if [ "${ASSEMBLY_PIPELINE}" == "True" ]; then
    # eggnog 2.0.0 on diamond 0.9.24
    wget $FTP_DBS/eggnog_proteins.dmnd
    wget $FTP_DBS/eggnog.db
    mkdir eggnog && mv eggnog_proteins.dmnd eggnog.db eggnog

    # Diamond
    wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/db_uniref90_result.txt.gz \
        ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/uniref90_${UNIREF90_VERSION}_diamond-v${DIAMOND_VERSION}.dmnd.gz
    gunzip db_uniref90_result.txt.gz uniref90_${UNIREF90_VERSION}_diamond-v${DIAMOND_VERSION}.dmnd.gz
    mkdir diamond && mv db_uniref90_result.txt uniref90_${UNIREF90_VERSION}_diamond-v${DIAMOND_VERSION}.dmnd diamond

    # KEGG pathways
    wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/graphs.pkl.gz \
       ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/all_pathways_class.txt.gz \
       ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/all_pathways_names.txt.gz
    gunzip graphs.pkl.gz all_pathways_class.txt.gz all_pathways_names.txt.gz
    mkdir kegg_pathways && mv graphs.pkl all_pathways_class.txt all_pathways_names.txt kegg_pathways

    # antismash summary - doesn't need for docker version
    wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/antismash_glossary.tsv.gz
    gunzip antismash_glossary.tsv.gz
fi

# GO-config

# Genome Properties flatfiles
# https://github.com/ebi-pf-team/genome-properties/tree/master/flatfiles

# ======== WGS
# mOTUs db would be in docker
# wget https://github.com/motu-tool/mOTUs_v2/archive/$MOTUS_VERSION.tar.gz && tar xvzf $MOTUS_VERSION.tar.gz && rm $MOTUS_VERSION.tar.gz && python3 mOTUs_v2-$VERSION/setup.py