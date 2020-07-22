class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  s: 'http://schema.org/'

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'

requirements:
  - class: ResourceRequirement
    ramMin: 20000
    ramMax: 20000
    coresMax: 4
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement

baseCommand: ['grep', '-v', '^#']

inputs:
  table:
    type: File
    inputBinding:
      position: 1

stdout: $(inputs.table.nameroot)_without_header$(inputs.table.nameext)
stderr: stderr.txt

outputs:
  result:
    type: stdout
  stderr: stderr

$schemas:
  - 'https://schema.org/version/latest/schemaorg-current-http.rdf'
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2018"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:author: "Ekaterina Sakharova"