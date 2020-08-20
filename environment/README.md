# Conda environments

We recommend the usage of miniconda for the installation of the different enviroments.

## [Toil](http://toil.ucsc-cgl.org/)

CWL execution engine.

Create the env `conda env create -f toil.yml`

Citation: [http://doi.org/10.1038/nbt.3772](http://doi.org/10.1038/nbt.3772)

## [antiSMASH 4.2.0](https://antismash.secondarymetabolites.org)

antiSMASH: Rapid identification, annotation and analysis of secondary metabolite biosynthesis gene clusters.

Citation: [http://dx.doi.org/10.1093/nar/gkx319](http://dx.doi.org/10.1093/nar/gkx319)http://dx.doi.org/10.1093/nar/gkx319)

Create the env `conda env create -f antismash.yml`

## [InterProScan](https://www.ebi.ac.uk/interpro/)

The conda env for interproscan doesn't include the application itself. To get the application:

Download from [ebi ftp](ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.36-75.0/interproscan-5.36-75.0-64-bit.tar.gz) and follow the instructions.

Then create the java env if you your env doesn't meet the minimal requirements. 

Use conda to install the proper version of java (`conda env -p interproscan.yml`)

Release: [https://www.ebi.ac.uk/interpro/release_notes/75.0/](https://www.ebi.ac.uk/interpro/release_notes/75.0/)