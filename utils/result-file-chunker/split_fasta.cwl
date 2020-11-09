#!/usr/bin/env
cwlVersion: v1.1
class: CommandLineTool

label: "Tool does chunking of input fasta by target size using genometools.
        If initial file has less number of lines than line_number: output == input;
        Else if file was chunked: output == [ prefix_NUMBER.ext];
        ( NUMBER has 2 digits format, ext == nameext of infile)"

requirements:
  - class: ResourceRequirement
    ramMin: 5000
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.genometools:latest

inputs:
  infile:
    type: File
    inputBinding:
      prefix: -i
  type_fasta: string  # n=nucleotide, p=protein

arguments:
    - prefix: -n
      valueFrom: |
        ${
          if (inputs.type_fasta == 'n') {
            return 1
          }
          if (inputs.type_fasta == 'p') {
            return 1
          }
        }

baseCommand: [ split_fasta_by_size.sh ]

outputs:
  chunks:
    type: File[]
    outputBinding:
      glob: "*.fasta.*"
      outputEval: |
        ${
          if (self.length == 1) {
            self[0].basename = inputs.infile.basename
            return self
          }
          var list_new_files = [];
          for (const cur_file of self) {
            cur_file.basename = inputs.infile.nameroot + "_" + cur_file.basename.split('.').pop() + inputs.infile.nameext;
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
