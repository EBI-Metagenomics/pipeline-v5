class: Workflow
cwlVersion: v1.0

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
$schemas:
  - 'http://edamontology.org/EDAM_1.20.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'

requirements:
  - class: ResourceRequirement
    ramMin: 10000
    coresMin: 32
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  fasta_file: File
  db_diamond: File
  db: File
  data_dir: string

outputs:
  eggnogg_combine_annotations:
    type: File
    outputSource: combine_annotations/result
  eggnog_combine_orthologs:
    type: File
    outputSource: combine_orthologs/result

steps:

  split_seqs:
    run: ../chunks/fasta_chunker.cwl
    in:
      seqs: fasta_file
      chunk_size: { default: 1000 }
    out: [ chunks ]

# << Functional annotation. eggnog >>
  eggnog:
    scatter: fasta_file
    run: eggnog-subwf.cwl
    in:
      fasta_file: split_seqs/chunks
      db_diamond: db_diamond
      db: db
      data_dir: data_dir
    out: [ annotations, orthologs ]

# << Unite annotations >>
  combine_annotations:
    run: ../chunks/concatenate.cwl
    in:
      files: eggnog/annotations
      outputFileName: { default: 'annotations_united' }
    out: [ result ]

# << Unite orthologs >>
  combine_orthologs:
    run: ../chunks/concatenate.cwl
    in:
      files: eggnog/orthologs
      outputFileName: { default: 'orthologs_united' }
    out: [ result ]

# << Add header >>
# written but not tested