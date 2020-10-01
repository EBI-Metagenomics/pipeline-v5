cwlVersion: v1.0
class: Workflow

label: "First scatter to find seed orthologs, unite them, find annotations"

requirements:
  ScatterFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:
  fasta_file: File[]
  db_diamond: [string, File]
  db: [string, File]
  data_dir: [string, Directory]
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
    run: ../../../utils/concatenate.cwl
    in:
      files: eggnog_homology_searches/output_orthologs
      outputFileName:
        source: file_acc
        valueFrom: $(self.split('_CDS')[0])
      postfix: { default: .emapper.seed_orthologs }
    out: [result]

  eggnog_annotation:
    run: eggNOG/eggnog.cwl
    in:
      annotate_hits_table: unite_seed_orthologs/result
      data_dir: data_dir
      no_file_comments: {default: true}
      cpu: cpu
      output:
        source: file_acc
        valueFrom: $(self.split('_CDS')[0])
    out: [ output_annotations ]


$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'

$schemas:
  - 'http://edamontology.org/EDAM_1.16.owl'
  - 'https://schema.org/version/latest/schemaorg-current-http.rdf'
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2018"
s:author: "Ekaterina Sakharova"