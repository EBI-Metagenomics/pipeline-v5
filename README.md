[![Build Status](https://travis-ci.org/EBI-Metagenomics/pipeline-v5.svg?branch=master)](https://travis-ci.com/EBI-Metagenomics/pipeline-v5)

# pipeline-v5

This repository contains all CWL descriptions of the MGnify pipeline version 5.0.

## Documentation

https://emg-docs.readthedocs.io/en/latest/analysis.html#overview

We recommend you use our pre-build docker containers. 
## Requirements to run pipeline 

- python3 [v 3.6+]
- docker [v 19.+] or singularity
- cwltool [v 3.+]

- memory for databases ~133G

## Installation
```bash
git clone https://github.com/EBI-Metagenomics/pipeline-v5.git 
cd pipeline-v5
```
#### Download necessary dbs
We have 3 pipelines (amplicon, assembly and wgs) in one repository. You can download dbs for single or multiple analysis types. <br>
Script **download_dbs.sh** has 3 arguments: -m (amplicon), -a (assembly), -w (raw reads / WGS). <br>
To download only amplicon databases do ```-m True -a False -w False```.
```bash
bash download_dbs.sh -a True -m True -w True  # for all types
```

#### Create yml-file
Set DIRECTORY as path to the same directory where you downloaded all databases. <br>
TYPE: assembly/wgs/amplicon
```bash
python3 create_yml.py --dir <DIRECTORY> --type <TYPE> 
```
If you need to generate several YML-files, run this script several times with different TYPEs.

## Run
Before running the pipeline, you need to add lines to the YML files detailing the sequence type and path to FASTA/FASTQ file(-s). <br>
**Amplicon** and **Raw reads** analysis can be performed on single-end or paired-end FASTQ file(-s). <br>
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
export TYPE=[single/paired/""]
cwltool workflows/conditionals/${ANALYSIS}-wf-${TYPE}-v.5-cond.cwl ${ANALYSIS}.yml
```
#### Other cwl-supported tools
https://www.commonwl.org/#Implementations


## Docker 
Pipeline uses dockers from MGnify DockerHub. <br>
If you have problems with pulling dockers, you can re-build them with:
```bash
bash docker/docker_build.sh
```


