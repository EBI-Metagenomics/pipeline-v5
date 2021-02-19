[![Build Status](https://travis-ci.org/EBI-Metagenomics/pipeline-v5.svg?branch=master)](https://travis-ci.com/EBI-Metagenomics/pipeline-v5)

# pipeline-v5

This repository contains all CWL descriptions of the MGnify pipeline version 5.0.

## Documentation

https://emg-docs.readthedocs.io/en/latest/analysis.html#overview

### We kindly recommend use our resource https://www.ebi.ac.uk/metagenomics/ for data processing.

If you want to run pipeline locally, we recommend you use our pre-build docker containers. 

## Requirements to run pipeline 

- python3 [v 3.6+]
- docker [v 19.+] or singularity
- cwltool [v 3.+] or toil [v 4.2+]

- hdd for databases ~133G

### Docker

All the tools are containerized. 

Unfortunately, antiSMASH and InterProScan containers are very big. We provide two options:
1. Pre-install these tools. The instructions on how to setup the environment are [here](environment/README.md).

2. Use containers. First of all you need to uncomment *hints* in **InterProScan-v5.cwl** and **antismash_v4.cwl**.
Pre-pull containers from https://hub.docker.com/u/microbiomeinformatics
```bash
docker pull microbiomeinformatics/pipeline-v5.interproscan:v5.36-75.0
docker pull microbiomeinformatics/pipeline-v5.antismash:v4.2.0
```


## Installation

```bash
git clone https://github.com/EBI-Metagenomics/pipeline-v5.git 
cd pipeline-v5
```

#### Download necessary dbs

We have 3 pipelines (amplicon, assembly and wgs) in one repository. You can download dbs for single or multiple analysis types.

Script **download_dbs.sh** has 3 arguments: -m (amplicon), -a (assembly), -w (raw reads / WGS).

To download only amplicon databases do ```-m True -a False -w False```.

```bash
mkdir ref-dbs && cd ref-dbs
bash ../Installation/download_dbs.sh -a True -m True -w True  # for all types
cd ..
```

#### Create yml-file
Set DIRECTORY as path to the same directory where you downloaded all databases (ref-dbs).

TYPE: assembly/wgs/amplicon

```bash
python3 Installation/create_yml.py --dir <DIRECTORY> --type <TYPE> 
# example: python3 Installation/create_yml.py --dir ref-dbs --type assembly
```

If you need to generate several YML-files, run this script several times with different TYPEs.

## Run

Before running the pipeline, you need to add lines to the YML files detailing the sequence type and path to FASTA/FASTQ file(-s).

**Amplicon** and **Raw reads** analysis can be performed on single-end or paired-end FASTQ file(-s). 

**Assembly** pipeline requires a contig FASTA file.

- If you are running amplicon or raw-reads **single** analysis - you need to add to generated YML-file:

```bash
single_reads:  
  format: edam:format_1930
  class: File
  path: <path to FASTQ file>
```

- If you are running amplicon or raw-reads **paired** analysis - you need to add to generated YML-file:

```bash
forward_reads:  
  format: edam:format_1930
  class: File
  path: <path to forward reads FASTQ file>
reverse_reads:  
  format: edam:format_1930
  class: File
  path: <path to reverse reads FASTQ file>
```

- If you are running **assembly** analysis - you need to add to generated YML-file:

```bash
contigs:  
  format: edam:format_1929
  class: File
  path: <path to FASTA file>
```

#### cwltool

```bash
export ANALYSIS=[amplicon/assembly/raw-reads]

cwltool --enable-dev workflows/${ANALYSIS}-wf--v.5-cond.cwl ${ANALYSIS}.yml
```

#### toil

```bash
export ANALYSIS=[amplicon/assembly/raw-reads]

toil-cwl-runner \
  --preserve-entire-environment \
  --enable-dev \
  --disableChaining \
  --logFile toil.log \
  --jobStore work-directory \
  --outdir results-folder \
  ${ANALYSIS}-wf--v.5-cond.cwl ${ANALYSIS}.yml
```

#### Other cwl-supported tools

https://www.commonwl.org/#Implementations

## Docker problems

Pipeline uses dockers from MGnify DockerHub.

If you have problems pulling the docker containers, you can re-build them with:

```bash
bash docker/docker_build.sh
```
