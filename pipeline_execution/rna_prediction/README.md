
This workflow runs a conditional QC step, RNA prediction and classification against SILVA databases.


# Setup

Required databases

```bash
$ ./scripts/rna_prediction_download_dbs.sh
```

# Execution

Source the tool and CWL environments before executing the following script.

The [rna_prediction_slurm.sh](scripts/rna_prediction_slurm.sh) script is used to trigger the CWL + Toil workflows using the SLURM batch system.

```shell
$ rna_prediction_slurm.sh -h

Run MGnify pipeline.
Script arguments.
  Resources:
  -m                  Memory to use to with toil --defaultMemory. (optional, default 50G)
  -c                  Number of cpus to use with toil --defaultCores. (optional, default 4)
  -l                  Limit number of jobs to schedule. (optional, default 100)

  Pipeline parameters:
  -y                  template yml file. (optional, default ../templates/rna_prediction_template.yml)
  -f                  Forward reads fasta file path.
  -r                  Reverse reads fasta file path.
  -s                  Single reads fasta file path.
  -q                  Run qc ('true' or 'false').
  -n                  Name of run and prefix to output files.
  -d                  Path to run directory.
  -p                  Path to database directory. (optional, default ../ref-dbs)
```
