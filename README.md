[![Build Status](https://travis-ci.com/EBI-Metagenomics/pipeline-v5.svg?token=Fx66TMEyQXwD4SBCCvpz&branch=master)](https://travis-ci.com/EBI-Metagenomics/pipeline-v5)

# pipeline-v5

This repository contains all CWL descriptions of the MGnify pipeline version 5.0.


### Download necessary dbs
```bash
# ---------------- common files:
mkdir ref-dbs && cd ref-dbs && 
# download silva dbs
mkdir silva_ssu silva_lsu
wget \
  ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/silva_ssu-20200130.tar.gz \
  ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/silva_lsu-20200130.tar.gz 
tar --extract --gzip --directory=silva_ssu silva_ssu-20200130.tar.gz
tar --extract --gzip --directory=silva_lsu silva_lsu-20200130.tar.gz
# download Pfam ribosomal models
mkdir ribosomal
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rfam_models/ribosomal_models/RF*.cm \
  ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rfam_models/ribosomal_models/ribo.claninfo \
  -P ribosomal 
  
  
# ----------------- AMPLICON -----------------
mkdir UNITE
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/UNITE-20200214.tar.gz
tar --extract --gzip --directory=UNITE UNITE-20200214.tar.gz

mkdir ITSonedb
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/ITSoneDB-20200214.tar.gz
tar --extract --gzip --directory=ITSonedb ITSoneDB-20200214.tar.gz


# ----------------- WGS -----------------
# rRNA.claninfo
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rRNA.claninfo
# other Rfam models
mkdir other
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rfam_models/other_models/*.cm \
  -P other 
# kofam db  
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/db_kofam.hmm.h3?.gz
# InterProScan
wget ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.36-75.0/interproscan-5.36-75.0.tar.gz
tar --extract --gzip interproscan-5.36-75.0.tar.gz


# ----------------- ASSEMBLY -----------------
# rRNA.claninfo
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rRNA.claninfo
# other Rfam models
mkdir other
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/rfam_models/other_models/*.cm \
  -P other 
# kofam db  
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/db_kofam.hmm.h3?.gz
# InterProScan
wget ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.36-75.0/interproscan-5.36-75.0.tar.gz
tar --extract --gzip interproscan-5.36-75.0.tar.gz
# Diamond
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/db_uniref90_result.txt.gz \
    ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/uniref90_v2019_08_diamond-v0.9.25.dmnd.gz
gunzip db_uniref90_result.txt.gz uniref90_v2019_08_diamond-v0.9.25.dmnd.gz
# KEGG pathways
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/graphs.pkl.gz \
   ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/all_pathways_class.txt.gz \
   ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/all_pathways_names.txt.gz
gunzip graphs.pkl.gz all_pathways_class.txt.gz all_pathways_names.txt.gz
# antismash summary
wget ftp://ftp.ebi.ac.uk/pub/databases/metagenomics/pipeline-5.0/ref-dbs/antismash_glossary.tsv.gz
gunzip antismash_glossary.tsv.gz
# EggNOG ??
#eggnog-mapper/data/eggnog.db, eggnog-mapper/data/eggnog_proteins.dmnd
# Genome Properties ??
# flatfiles?


```

