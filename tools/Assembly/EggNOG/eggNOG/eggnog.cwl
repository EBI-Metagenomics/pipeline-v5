#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "eggNOG"

hints:
  DockerRequirement:
    dockerPull: eggnog_pipeline:latest

requirements:
  ResourceRequirement:
    ramMin: 40000
    coresMin: 32
#  InlineJavascriptRequirement: {}

baseCommand: [emapper.py]

inputs:
  fasta_file:
    type: File?
    inputBinding:
      separate: true
      prefix: -i
    label: Input FASTA file containing query sequences

  db:
    type: File?  # data/eggnog.db
    inputBinding:
      prefix: --database
    label: specify the target database for sequence searches (euk,bact,arch, host:port, local hmmpressed database)

  db_diamond:
    type: File?  # data/eggnog_proteins.dmnd
    inputBinding:
      prefix: --dmnd_db
    label: Path to DIAMOND-compatible database

  data_dir:
    type: string?  # data/
    inputBinding:
      prefix: --data_dir
    label: Directory to use for DATA_PATH

  mode:
    type: string?
    inputBinding:
      prefix: -m
    label: hmmer or diamond

  no_annot:
    type: boolean?
    inputBinding:
      prefix: --no_annot
    label: Skip functional annotation, reporting only hits

  no_file_comments:
    type: boolean?
    inputBinding:
      prefix: --no_file_comments
    label: No header lines nor stats are included in the output files

  cpu:
    type: int?
    inputBinding:
      prefix: --cpu

  annotate_hits_table:
    type: File?
    inputBinding:
      prefix: --annotate_hits_table
    label: Annotatate TSV formatted table of query->hits

  output:
    type: string?
    inputBinding:
      prefix: -o

outputs:

  output_annotations:
    type: File?
    outputBinding:
      glob: $(inputs.output)*annotations*

  output_orthologs:
    type: File?
    outputBinding:
      glob: $(inputs.output)*orthologs*