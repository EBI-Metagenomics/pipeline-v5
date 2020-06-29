cwlVersion: v1.0
class: Workflow
$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'

requirements:
  ScatterFeatureRequirement: {}
  ResourceRequirement:
    ramMin: 20000
    coresMin: 32

inputs:
  seqfile: File
  gathering_bit_score: boolean
  name_database: string
  data: Directory
  omit_alignment: boolean

outputs:
  output_table:
    type: File
    format: edam:format_3475
    outputSource: make_tab_sep/output_with_tabs

steps:
  hmmscan:
    run: hmmscan.cwl
    in:
      seqfile: seqfile
      gathering_bit_score: gathering_bit_score
      name_database: name_database
      data: data
      omit_alignment: omit_alignment
    out: [ output_table ]
    label: "Analysis using profile HMM on db"

  make_tab_sep:
    run: ../../../utils/hmmscan_tab_modification/hmmscan_tab_modification.cwl
    in:
      input_table: hmmscan/output_table
    out: [ output_with_tabs ]

  #remove_header:
  #  run: ../chunks/remove_headers.cwl
  #  in:
  #    table: hmmscan/output_table
  #  out: [ result, stderr ]

$schemas:
  - 'http://edamontology.org/EDAM_1.16.owl'
  - 'https://schema.org/version/latest/schema.rdf'
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2018"
s:author: "Ekaterina Sakharova"