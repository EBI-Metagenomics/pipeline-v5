#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: "v1.0"
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 2
    ramMin: 200  # just a default, could be lowered

baseCommand: [bash, /hps/nobackup2/production/metagenomics/pipeline/testing/kate/pipeline-v5/utils/count_fastq/count_fastq.sh]

inputs:
  sequences:
    type: File
    inputBinding:
      prefix: -f

outputs:
  count:
    type: int
    outputBinding:
      glob: data.txt
      loadContents: true
      outputEval: $(parseInt(self[0].contents))

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'

$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:license': "https://www.apache.org/licenses/LICENSE-2.0"
's:copyrightHolder': "EMBL - European Bioinformatics Institute"
