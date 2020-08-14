class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  s: 'http://schema.org/'

label: Redirecting Multiple Files Contain in a Single File

hints:
  - class: DockerRequirement
    dockerPull: debian:stable-slim

baseCommand: [ cat ]

inputs:
  files:
    type: File[]
    inputBinding:
      position: 1
  outputFileName: string
  postfix: string?

stdout: $(inputs.outputFileName)$(inputs.postfix)

outputs:
  - id: result
    type: stdout
    format: ${if ("format" in inputs.files[0]) return inputs.files[0].format; else return 'undefined'}

doc: >
  The cat (short for concatenate) command is one of the most frequently used command in
  Linux/Unix like operating systems. cat command allows us to create single or multiple
  files, view contain of file, concatenate files and redirect output in terminal or files.

requirements:
  - class: ResourceRequirement
    ramMin: 200
    coresMax: 1
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement


$schemas:
  - 'https://schema.org/version/latest/schemaorg-current-http.rdf'
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2018"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:author: "Michael Crusoe, Maxim Scheremetjew"