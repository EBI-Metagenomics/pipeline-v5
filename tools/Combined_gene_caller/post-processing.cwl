#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Combined Gene Caller: post-processing of FGS and Prodigal"

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.protein-post-processing:v1.0.1

requirements:
  ResourceRequirement:
    ramMin: 5000
    coresMin: 4

baseCommand: [ unite_protein_predictions.py ]

inputs:
  masking_file:
    type: File?
    inputBinding:
      prefix: "--mask"
  predicted_proteins_prodigal_out:
    type: File?
    inputBinding:
      prefix: "--prodigal-out"
  predicted_proteins_prodigal_ffn:
    type: File?
    inputBinding:
      prefix: "--prodigal-ffn"
  predicted_proteins_prodigal_faa:
    type: File?
    inputBinding:
      prefix: "--prodigal-faa"
  predicted_proteins_fgs_out:
    type: File
    inputBinding:
      prefix: "--fgs-out"
  predicted_proteins_fgs_ffn:
    type: File
    inputBinding:
      prefix: "--fgs-ffn"
  predicted_proteins_fgs_faa:
    inputBinding:
      prefix: "--fgs-faa"
    type: File
  basename:
    inputBinding:
      prefix: "--name"
    type: string
  genecaller_order:
    inputBinding:
      prefix: "--caller-priority"
    type: string?


stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr

  predicted_proteins:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: $(inputs.basename).faa
  predicted_seq:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: $(inputs.basename).ffn

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