cwlVersion: v1.0
class: Workflow
$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'

requirements:
  - class: ScatterFeatureRequirement

inputs:
  input_file: File
  gathering_bit_score: boolean
  name_database: string
  data: Directory
  omit_alignment: boolean

outputs:
  hmm_result:
    type: File
    outputSource: remove_header/result

steps:
  hmmscan:
    run: hmmscan.cwl
    in:
      seqfile: input_file
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

$schemas:
  - 'http://edamontology.org/EDAM_1.16.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2018"
s:author: "Ekaterina Sakharova"