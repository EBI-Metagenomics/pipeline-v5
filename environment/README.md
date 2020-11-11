# Conda environments

We recommend the usage of [miniconda](https://docs.conda.io/en/latest/miniconda.html) for the installation of the different environments.

## [Toil](http://toil.ucsc-cgl.org/)

CWL execution engine.

Create the env 'conda env create -f toil.yml', add '-n' to specify a name for the env.

Citation: [http://doi.org/10.1038/nbt.3772](http://doi.org/10.1038/nbt.3772)

## [antiSMASH 4.2.0](https://antismash.secondarymetabolites.org)

antiSMASH: Rapid identification, annotation and analysis of secondary metabolite biosynthesis gene clusters.

Citation: [http://dx.doi.org/10.1093/nar/gkx319](http://dx.doi.org/10.1093/nar/gkx319)http://dx.doi.org/10.1093/nar/gkx319)

Create the env 'conda env create -f antismash.yml', add '-n' to specify a name for the env.

## [InterProScan 5.36-75.0](https://www.ebi.ac.uk/interpro/)

The conda env for interproscan doesn't include the application itself.

To get the application:

Download from ebi ftp [ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.36-75.0/interproscan-5.36-75.0-64-bit.tar.gz](ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.36-75.0/interproscan-5.36-75.0-64-bit.tar.gz) and follow the installation instructions [https://github.com/ebi-pf-team/interproscan/wiki](https://github.com/ebi-pf-team/interproscan/wiki).

InterproScan requirements are: python3, perl 5 and java. If your environment doesn't meet the minimum requirements you can use the provided conda environment:

- 'conda env -p interproscan.yml', add '-n' to specify a name for th env.

Release: [https://www.ebi.ac.uk/interpro/release_notes/75.0/](https://www.ebi.ac.uk/interpro/release_notes/75.0/)

### Setup interproscan.sh

Adjust interproscan.sh in the inteproscan installation folder. It is needed to source and activate the conda env (in cas)