# CWL Test for the QC and RNA prediction workflow

# Setup

To run the tests with [toil](toil.readthedocs.io/)

```bash
$ pip install cwltest toil[cwl] 
```

To run them with [cwltool](cwltool.readthedocs.io/)
```bash
$ pip install cwltest cwltool
```

This requires Docker or singularity

## Download the ref dbs

```bash
# Download the databases using the pipeline_execution/rna_prediction/scripts/rna_prediction_download_dbs.sh script
$ rna_prediction_download_dbs.sh -o ref-dbs
```

# Execution with Toil

```
$ cwltest --test tests.yml --tool --tool toil-cwl-runner -- --disableProgress
```

to use singularity add the `--singularity` flag

# Execution with cwltool
```
$ cwltest --test tests.yml --tool cwltool
```

to use singularity add the `-- --singularity --singularity` flag