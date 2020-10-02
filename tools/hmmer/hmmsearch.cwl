#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

label: "Biosequence analysis using profile hidden Markov models"

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/hmmer:3.2.1--hf484d3e_1

requirements:
  ShellCommandRequirement: {}
  ScatterFeatureRequirement: {}
  ResourceRequirement:
    ramMin: 6000
    coresMin: 4
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing: |
      ${
        if (typeof inputs.database_dir !== undefined) {
            // this folder should have all the hmm aux files (.h3{mifp})
            // uncompressed
            return inputs.database_dir.listing;
        }
        return [];
      }

baseCommand: ["hmmsearch"]

arguments:
  - valueFrom: '> /dev/null'
    shellQuote: false
    position: 10
  - valueFrom: '2> /dev/null'
    shellQuote: false
    position: 11
  - prefix: --domtblout
    valueFrom: $(inputs.seqfile.nameroot)_hmmsearch.tbl
    position: 2
  - prefix: --cpu
    valueFrom: '4'
  - prefix: -o
    valueFrom: '/dev/null'

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
    inputBinding:
      position: 5
  
  database_directory:
    type: Directory?
    doc: |
      "Database path"

  seqfile:
    format: edam:format_1929  # FASTA
    type: File
    inputBinding:
      position: 6
      separate: true

outputs:
  output_table:
    type: File
    format: edam:format_3475
    outputBinding:
      glob: "*_hmmsearch.tbl"

$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: "Ekaterina Sakharova"
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"