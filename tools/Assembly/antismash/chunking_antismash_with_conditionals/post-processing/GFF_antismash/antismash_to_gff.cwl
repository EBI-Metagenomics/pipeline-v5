#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Script builds GFF-file based on antiSMASH results"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

hints:
  DockerRequirement:
    dockerPull:  microbiomeinformatics/pipeline-v5.python3:v3.1

baseCommand: [ antismash_to_gff_nojson.py ]

inputs:
  antismash_geneclus:
    type: File
    inputBinding:
      prefix: -g
  antismash_embl:
    type: File
    inputBinding:
      prefix: -e
  output_name:
    type: string
    inputBinding:
      prefix: -o

stdout: stdout.txt

outputs:
  output_gff_bgz:
    type: File
    format: edam:format_2306  # GTF/GFF
    outputBinding:
      glob: $(inputs.output_name).bgz
  output_gff_index:
    type: File
    outputBinding:
      glob: $(inputs.output_name).bgz.tbi
  stdout: stdout

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: 'Martin Beracochea, Ekaterina Sakharova, Varsha Kale'
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"