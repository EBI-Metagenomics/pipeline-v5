class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  s: 'http://schema.org/'

#hints:
#  - class: DockerRequirement
#    dockerPull: 'alpine:3.7'

requirements:
  - class: ResourceRequirement
    ramMin: 10000
    ramMax: 10000
    coresMax: 16
  - class: InlineJavascriptRequirement

baseCommand: ['grep', '-v', '^#']

inputs:
  table:
    type: File
    inputBinding:
      position: 1

stdout: $(inputs.table.nameroot)_without_header$(inputs.table.nameext)

outputs:
  result:
    type: stdout

$schemas:
  - 'https://schema.org/docs/schema_org_rdfa.html'
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2018"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:author: "Ekaterina Sakharova"