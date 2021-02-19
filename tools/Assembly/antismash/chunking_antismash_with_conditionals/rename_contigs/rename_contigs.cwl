#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "rename contigs for chunk fastas"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 1000

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.python3:v3.1

inputs:
  full_fasta:
    type: File
    inputBinding:
      prefix: -i
  chunks:
    type: File
    inputBinding:
      prefix: -c
  accession:
    type: string
    inputBinding:
      prefix: -a

baseCommand: [ antismash_rename_contigs.py ]

outputs:
  renamed_contigs_in_chunks:
    format: edam:format_1929  # FASTA
    type: File
    outputBinding:
      glob: antismash.*
  names_table:
    type: File
    outputBinding:
      glob: $(inputs.chunks.basename).tbl


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: "Ekaterina Sakharova"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"