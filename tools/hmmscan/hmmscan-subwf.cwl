cwlVersion: v1.0
class: Workflow
$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'

requirements:
  - class: ScatterFeatureRequirement

inputs:
  seqfile: File
  gathering_bit_score: boolean
  name_database: string
  data: Directory
  omit_alignment: boolean

outputs:
  output_table:
    type: File
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

  remove_header:
    run: ../chunks/remove_headers.cwl
    in:
      table: hmmscan/output_table
    out: [ result ]

  make_tab_sep:
    run: ../../utils/make_tab_sep.cwl
    in:
      input_table: remove_header/result
    out: [ output_with_tabs ]

$schemas:
  - 'http://edamontology.org/EDAM_1.16.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2018"
s:author: "Ekaterina Sakharova"