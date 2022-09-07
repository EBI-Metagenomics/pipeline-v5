#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

baseCommand: ["grep", "-c", "^>"]

inputs:
  sequences:
    type: File
    streamable: true
    inputBinding: {position: 1}
  number:
    type: int

arguments:
  - valueFrom: '|'
    position: 2
    shellQuote: false
  - valueFrom: cat
    shellQuote: false
    position: 3

stdout: grepcount

outputs:
  count:
    type: int
    outputBinding:
      glob: grepcount
      loadContents: true
      outputEval: |
        ${
          var grep_count = parseInt(self[0].contents) || 0;
          if (grep_count === 0) {
            return 0;
          } else {
            return parseInt(grep_count / inputs.number);
          }
        }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"