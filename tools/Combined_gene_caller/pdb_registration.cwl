#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

label: "ProteinDB registration, search and add new proteins in ProteinDB"

#hints:
#  - class: DockerRequirement
#    dockerPull:

requirements:
  ResourceRequirement:
    ramMin: 2000
    coresMin: 1

baseCommand: [ pdb_registration.py ]

inputs:
  prot_fasta:
    type: File
    inputBinding:
      prefix: "--fasta"
  pdb_config:
    type: File
    inputBinding:
      prefix: "--config"  

stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr

  pdb_result:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: $(inputs.prot_fasta.basename).pdb.faa
  

$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"