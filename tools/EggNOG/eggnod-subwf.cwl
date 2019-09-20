cwlVersion: v1.0
class: Workflow
$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'

requirements:
  - class: ScatterFeatureRequirement

inputs:
  fasta_file: File
  db_diamond: File
  db: File
  data_dir: string

outputs:
  annotations:
    type: File
    outputSource: remove_header_annotations/result
  orthologs:
    type: File
    outputSource: remove_header_orthologs/result

steps:
  eggnog:
    run: eggNOG/eggnog.cwl
    in:
      fasta_file: fasta_file
      db_diamond: db_diamond
      db: db
      data_dir: data_dir
    out: [ output_annotations, output_orthologs ]

  remove_header_annotations:
    run: ../chunks/remove_headers.cwl
    in:
      table: eggnog/output_annotations
    out: [ result ]

  remove_header_orthologs:
    run: ../chunks/remove_headers.cwl
    in:
      table: eggnog/output_orthologs
    out: [ result ]
$schemas:
  - 'http://edamontology.org/EDAM_1.16.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2018"
s:author: "Ekaterina Sakharova"