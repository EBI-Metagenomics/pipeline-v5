#!/usr/bin/env
cwlVersion: v1.2
class: CommandLineTool

label: "Tool does chunking of input table by number of lines in line_number.
        If initial file has less number of lines than line_number: output == input;
        Else if file was chunked: output == [ prefix_NUMBER.ext];
        ( NUMBER has 2 digits format, ext == nameext of infile)"

requirements:
  - class: ResourceRequirement
    ramMin: 5000
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: debian:stable-slim

inputs:
  infile:
    type: File
    inputBinding:
      position: 4
  line_number:
    type: int
    inputBinding:
      prefix: -l
  prefix:
    type: string
    inputBinding:
      position: 5

arguments: ["-d", "--numeric-suffixes=1", "-a", "3"]

baseCommand: [split]

outputs:
  chunks:
    type: File[]
    outputBinding:
      glob: "$(inputs.prefix)*"
      outputEval: |
        ${
          if (self.length == 0) {
            return [inputs.infile]
          }
          if (self.length == 1) {
            self[0].basename = inputs.infile.basename
            return self
          }

          var list_new_files = [];
          for (var i = 0; i < self.length; ++i) {
            var cur_file = self[i];
            cur_file.basename = cur_file.basename + inputs.infile.nameext;
            list_new_files.push(cur_file);
            }
          return list_new_files
        }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
