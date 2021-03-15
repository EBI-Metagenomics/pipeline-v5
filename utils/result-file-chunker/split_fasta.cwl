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
    dockerPull: microbiomeinformatics/pipeline-v5.split-fasta:v2

inputs:
  infile:
    type: File
    inputBinding:
      prefix: -i
  type_fasta:
    type: string?
    default: 'n'   # n=nucleotide, p=protein
  size_limit: int?

arguments:
    - prefix: -n
      valueFrom: |
        ${
          if (inputs.size_limit) { return inputs.size_limit }
          if (inputs.type_fasta == 'n') {
            return 1980
          }
          if (inputs.type_fasta == 'p') {
            return 1442
          }
        }

baseCommand: [ split_fasta_by_size.sh ]

outputs:
  chunks:
    type: File[]
    format: 'edam:format_1929'
    outputBinding:
      glob: "*.fasta*"
      outputEval: |
        ${
          if (self.length == 1) {
            self[0].basename = inputs.infile.basename
            return self
          }
          else {
            var list_new_files = [];
            for (var i = 0; i < self.length; ++i) {
              var cur_file = self[i];
              cur_file.basename = inputs.infile.nameroot + "_" + cur_file.basename.split('.').pop() + inputs.infile.nameext;
              list_new_files.push(cur_file);
              }
            return list_new_files }
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
