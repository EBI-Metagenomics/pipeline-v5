#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "identify amplicon data type and suppress the the others"

requirements:
    ResourceRequirement:
        coresMax: 1
        ramMin: 8000 #check profiles and lower

inputs:
    ssu_file:
      type: File
      inputBinding:
        prefix: --ssu-file
    lsu_file:
      type: File
      inputBinding:
        prefix: --lsu-file
    its_file:
      type: File
      inputBinding:
        prefix: --its-file
    lsu_dir:
      type: Directory
      default: "LSU"
      inputBinding:
        prefix: --lsu-dir
    ssu_dir:
      type: Directory
      default: "SSU"
      inputBinding:
        prefix: --ssu-dir
    its_dir:
      type: Directory
      default: "its"
      inputBinding:
        prefix: --its-dir


baseCommand: [its-length.py]
stdout: ITS_LENGTH

outputs:
    stdout: stdout
    out_lsu:
       type: Directory
       outputBinding:
        glob: "*LSU*"
    out_ssu:
       type: Directory
       outputBinding:
        glob: "*SSU*"
    out_its:
       type: Directory
       outputBinding:
        glob: "*its"
    out_fasta:
       type: File
       outputBinding:
        glob: "*.fasta.gz"

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'

$namespaces:
 s: http://schema.org/
 iana: https://www.iana.org/assignments/media-types/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"