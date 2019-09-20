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
    ramMin: 20000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  contigs: File

  ssu_db: {type: File, secondaryFiles: [.mscluster] }
  lsu_db: {type: File, secondaryFiles: [.mscluster] }
  ssu_tax: File
  lsu_tax: File
  ssu_otus: File
  lsu_otus: File

  rfam_models: File[]
  rfam_model_clans: File

  ssu_label: string
  lsu_label: string
  5s_pattern: string

outputs:
  count_reads:
    type: int
    outputSource: count_processed_reads/count

  qc_stats_out:
    type: Directory
    outputSource: qc_stats/output_dir

  ncRNAs:
    type: File
    outputSource: classify/ncRNAs

  cmsearch_tblout:
    type: File
    outputSource: classify/cmsearch_deoverlapped

  5s_fasta:
    type: File
    outputSource: classify/5S_fasta

  SSU_fasta:
    type: File
    outputSource: classify/SSU_fasta

  LSU_fasta:
    type: File
    outputSource: classify/LSU_fasta

  SSU_classifications:
    type: File
    outputSource: classify/SSU_classifications

  SSU_otu_tsv:
    type: File
    outputSource: classify/SSU_otu_tsv

  SSU_otu_txt:
    type: File
    outputSource: classify/SSU_otu_txt

  SSU_krona_image:
    type: File
    outputSource: classify/SSU_krona_image

  LSU_classifications:
    type: File
    outputSource: classify/LSU_classifications

  LSU_otu_tsv:
    type: File
    outputSource: classify/LSU_otu_tsv

  LSU_otu_txt:
    type: File
    outputSource: classify/LSU_otu_txt

  LSU_krona_image:
    type: File
    outputSource: classify/LSU_krona_image

steps:

# << COUNT READS >>
  count_processed_reads:
    run: ../utils/count_fasta.cwl
    in:
      sequences: contigs
    out: [ count ]

# << QC >>
  qc_stats:
    run: ../tools/qc-stats/qc-stats.cwl
    in:
      QCed_reads: contigs
      sequence_count: count_processed_reads/count
    out: [ output_dir, summary_out ]

# << RNA PREDICTION >>
  classify:
    run: rna_prediction-sub-wf.cwl
    in:
       input_sequences: contigs
       silva_ssu_database: ssu_db
       silva_lsu_database: lsu_db
       silva_ssu_taxonomy: ssu_tax
       silva_lsu_taxonomy: lsu_tax
       silva_ssu_otus: ssu_otus
       silva_lsu_otus: lsu_otus
       ncRNA_ribosomal_models: rfam_models
       ncRNA_ribosomal_model_clans: rfam_model_clans
       pattern_SSU: ssu_label
       pattern_LSU: lsu_label
       pattern_5S: 5s_pattern
    out:
      - ncRNAs
      - cmsearch_deoverlapped
      - 5S_fasta

      - SSU_fasta
      - SSU_coords
      - SSU_classifications
      - SSU_otu_tsv
      - SSU_otu_txt
      - SSU_krona_image

      - LSU_fasta
      - LSU_coords
      - LSU_classifications
      - LSU_otu_tsv
      - LSU_otu_txt
      - LSU_krona_image

#      - ssu_hdf5_classifications
#      - ssu_json_classifications
#      - lsu_hdf5_classifications
#      - lsu_json_classifications

# << CHUNKS >>

# << COMBINED GENE CALLER >>

# << FUNCTIONAL ANNOTATION SW >>

# << DIAMOND SW >>

# << VIRAL >>

# << UNITE CHUNKS >>