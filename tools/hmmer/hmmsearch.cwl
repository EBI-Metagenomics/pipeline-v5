#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Biosequence analysis using profile hidden Markov models"

requirements:
  ShellCommandRequirement: {}
  ScatterFeatureRequirement: {}
  ResourceRequirement:
    ramMin: 6000
    coresMin: 4
  InlineJavascriptRequirement: {}
  # TODO: this is required after fixing the problem with the workdir and the
  #       dbs being staged there - https://github.com/DataBiosphere/toil/issues/2534
  # 
  # InitialWorkDirRequirement:
  #   listing: |
  #     ${
  #       // if datatabse is an object then it's a Directory otherwise
  #       // it's a string
  #       var typeOfDir = typeof inputs.database_dir;
  #       if (typeOfDir === 'object') {
  #           // this folder should have all the hmm aux files (.h3{mifp})
  #           // uncompressed
  #           return inputs.database_dir.listing;
  #       }
  #       return [];
  #     }

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.hmmer:v3.2.1

baseCommand: ["hmmsearch"]

inputs:

  omit_alignment:
    type: boolean?
    inputBinding:
      position: 1
      prefix: "--noali"

  gathering_bit_score:
    type: boolean?
    inputBinding:
      position: 4
      prefix: "--cut_ga"

  database:
    type: string
    doc: |
      "Database name or path, depending on how your using it."
  
  database_directory:
    type: [string, Directory?]
    doc: |
      "Database path"

  seqfile:
    format: edam:format_1929  # FASTA
    type: File
    inputBinding:
      position: 6
      separate: true

arguments:
  - valueFrom: |
      ${
        if (inputs.database_directory && inputs.database_directory !== "") {
          var path = inputs.database_directory.path || inputs.database_directory; 
          return path + "/" + inputs.database;
        } else {
          return inputs.database;
        }
      }
    position: 5
  - prefix: --domtblout
    valueFrom: $(inputs.seqfile.nameroot)_hmmsearch.tbl
    position: 2
  - prefix: --cpu
    valueFrom: '4'
  # hmmer is too verbose
  # discard all the std output and error
  - prefix: -o
    valueFrom: '/dev/null'
  - valueFrom: '> /dev/null'
    shellQuote: false
    position: 10
  - valueFrom: '2> /dev/null'
    shellQuote: false
    position: 11

outputs:
  output_table:
    type: File
    format: edam:format_3475
    outputBinding:
      glob: "*_hmmsearch.tbl"

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: "Ekaterina Sakharova"
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"