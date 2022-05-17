#!/usr/bin/env
cwlVersion: v1.2
class: CommandLineTool

label: "Tool creates file NAME.chunks and add inside basenames of given list of files"

requirements:
  - class: ResourceRequirement
    ramMin: 500
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: debian:stable-slim

inputs:
  infile: File
  list_chunks: File[]

arguments:
  - position: 1
    valueFrom: |
      ${
        var return_string = "";
        for (var i = 0; i < inputs.list_chunks.length; ++i) {
          var cur_file = inputs.list_chunks[i];
          return_string = return_string + cur_file.basename + "\n";
        }
        return return_string;
      }

baseCommand: [ echo ]

stdout: $(inputs.infile.basename).chunks

outputs:
  chunks_file: stdout


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
