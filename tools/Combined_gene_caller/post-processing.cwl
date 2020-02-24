#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

label: "Combined Gene Caller: post-processing of FGS and Prodigal"

#hints:
#  - class: DockerRequirement
#    dockerPull:

requirements:
  ResourceRequirement:
    ramMin: 5000
    coresMin: 4

baseCommand: [ unite_protein_predictions.py ]

inputs:
  masking_file:
    type: File
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


$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:author': 'Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"