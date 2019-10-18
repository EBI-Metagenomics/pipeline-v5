cwlVersion: v1.0
class: Workflow
$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'

requirements:
  - class: ScatterFeatureRequirement

inputs:
  fasta_file: File[]
  db_diamond: File
  db: File
  data_dir: string

  cpu: int
  file_acc: string

outputs:
  annotations:
    type: File
    outputSource: eggnog_annotation/output_annotations
  orthologs:
    type: File
    outputSource: unite_seed_orthologs/result

steps:
  eggnog_homology_searches:
    scatter: fasta_file
    run: eggNOG/eggnog.cwl
    in:
      fasta_file: fasta_file
      db_diamond: db_diamond
      db: db
      data_dir: data_dir
      no_annot: {default: true}
      no_file_comments: {default: true}
      cpu: cpu
      output: file_acc
      mode: { default: diamond }
    out: [ output_orthologs ]

  unite_seed_orthologs:
    run: ../../chunks/concatenate.cwl
    in:
      files: eggnog_homology_searches/output_orthologs
      outputFileName: file_acc
      postfix: {default: .emapper.seed_orthologs }
    out: [result]

  eggnog_annotation:
    run: eggNOG/eggnog.cwl
    in:
      annotate_hits_table: unite_seed_orthologs/result
      data_dir: data_dir
      no_file_comments: {default: true}
      cpu: cpu
      output: file_acc
    out: [ output_annotations ]


$schemas:
  - 'http://edamontology.org/EDAM_1.16.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2018"
s:author: "Ekaterina Sakharova"