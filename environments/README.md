# Conda and virtual enviroments used in EBI compute cluster

Running the pipeline without containers is currently not recommended and not supported by the Microbiome Informatics team (https://www.ebi.ac.uk/metagenomics).

The following instructions are used on EBI infrastructure to run the pipeline.

## Environments

The pipeline needs 3 different conda enviroments:
- python3 (ebi-conda-py3.yml)
  + this is the enviroment used to run the pipeline with toil-cwl-runner
- python2 (ebi-conda-py2.yml)
- antismash4.2 (we don't provide the env, install using bioconda.)

## Python 3

Env with python3 and toil to run the pipeline.

File "ebi-conda-py3.yml".

## Python 2

Env with python 2 and other libraries.

File "ebi-conda-py2.yml".
