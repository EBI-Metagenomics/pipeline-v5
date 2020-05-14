#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: rename empty tax files and add mock bacteria to empty otu table
#this to avoid errors with empty files further down the pipeline

requirements:
  ResourceRequirement:
    ramMin: 1000
  ShellCommandRequirement: {}

hints:
  - class: DockerRequirement
    dockerPull: alpine:3.7

inputs:
  mapseq:
    type: File
    format: iana:text/tab-separated-values
    inputBinding:
      position: 1

  otutable:
    type: File
    format: edam:format_3746  # BIOM
    inputBinding:
      position: 2

  biomtable:
    type: File
    format: iana:text/tab-separated-values  # TXT
    inputBinding:
      position: 3

  krona:
    type: File
    format: iana:text/html  # HTML
    inputBinding:
      position: 4

  fasta:
    type: File
    format: edam:format_1929  # FASTA
    inputBinding:
      position: 5

  otunotaxid:
    type: File?
    format: edam:format_3746  # BIOM
    inputBinding:
        position: 6

baseCommand: [empty_tax.sh]

outputs:
  mapseq_out:
    type: File
    format: iana:text/tab-separated-values
    outputBinding:
      glob: "*.mseq"

  otu_out:
    type: File
    format: edam:format_3746  # BIOM
    outputBinding:
      glob: "*.mseq.tsv"

  biom_out:
    type: File
    format: iana:text/tab-separated-values  # TXT
    outputBinding:
      glob: "*.txt"

  krona_out:
    type: File
    format: iana:text/html   # HTML
    outputBinding:
      glob: "*.html"

  fasta_out:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: "*.fasta"

  otunotaxid_out:
    type: File
    format: edam:format_3746  # BIOM
    outputBinding:
        glob: "*.notaxid.tsv"


$namespaces:
 iana: https://www.iana.org/assignments/media-types/
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:author': 'Varsha Kale, Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"
