#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2.0-dev2

requirements:
#  - class: SchemaDefRequirement
#    types:
#      - $import: ../tools/Diamond/Diamond-strand_values.yaml
#      - $import: ../tools/Diamond/Diamond-output_formats.yaml
#      - $import: ../tools/InterProScan/InterProScan-apps.yaml
#      - $import: ../tools/InterProScan/InterProScan-protein_formats.yaml
  - class: ResourceRequirement
    ramMin: 50000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
    filtered_fasta: File

# << accessioning >>
    include_protein_assign: boolean
    public: int?
    config_db_file: File?
    run_accession: string?
    study_accession: string?
    generate_map_file_flag: boolean

 # << rna prediction >>
    ssu_db: {type: File, secondaryFiles: [.mscluster] }
    lsu_db: {type: File, secondaryFiles: [.mscluster] }
    ssu_tax: [string, File]
    lsu_tax: [string, File]
    ssu_otus: [string, File]
    lsu_otus: [string, File]

    rfam_models:
      type:
        - type: array
          items: [string, File]
    rfam_model_clans: [string, File]
    other_ncrna_models: string[]

    ssu_label: string
    lsu_label: string
    5s_pattern: string
    5.8s_pattern: string

 # << cgc >>
    CGC_config: [string?, File?]
    CGC_postfixes: string[]
    cgc_chunk_size: int
    fgs_train: string?
    genecaller_order: string?

 # << functional annotation >>
    protein_chunk_size_eggnog: int
    protein_chunk_size_hmm: int
    protein_chunk_size_IPS: int
    func_ann_names_ips: string
    func_ann_names_hmmer: string
    HMM_gathering_bit_score: boolean
    HMM_omit_alignment: boolean
    HMM_database: string
    HMM_database_dir: [string, Directory?]
    hmmsearch_header: string
    EggNOG_db: [string?, File?]
    EggNOG_diamond_db: [string?, File?]
    EggNOG_data_dir: [string, Directory]
    InterProScan_databases: [string, Directory]
    InterProScan_applications: string[]  # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
    InterProScan_outputFormat: string[]  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
    ips_header: string
    ko_file: [string, File]

 # << diamond >>
    Uniref90_db_txt: [string, File]
    diamond_maxTargetSeqs: int
    diamond_databaseFile: [string, File]
    diamond_header: string

 # << GO >>
    go_config: [string?, File?]

 # << Pathways >>
    graphs: [string, File]
    pathways_names: [string, File]
    pathways_classes: [string, File]

 # << genome properties >>
    gp_flatfiles_path: [string?, Directory?]

 # << antismash summary >>
    clusters_glossary: [string, File]

outputs:

 # << root folder >>
  compressed_files:                                          # [2] cmsearch, ncRNA
    type: File[]
    outputSource: compression/compressed_file
  index_fasta_with_indexes:                                  # [3] fasta.bgz.fai, fasta.bgz, fasta.bgz.gzi
    type: File[]
    outputSource:
      - fasta_index/fasta_index
      - fasta_index/fasta_bgz
      - fasta_index/bgz_index
  chunking_fasta_files:                                      # [6] fasta, ffn, faa, chunks
    type: File[]?
    outputSource: chunking_final/fasta_chunks

 # << functional annotation >>
  functional_annotation_folder:                              # [15]
    type: Directory
    outputSource: functional_annotation/functional_annotation_folder
  stats:                                                     # [6]
    outputSource: functional_annotation/stats
    type: Directory

 # << pathways and systems >>
  pathways_systems_folder:
    type: Directory
    outputSource: functional_annotation/pathways_systems_folder
  pathways_systems_folder_antismash_summary:
    type: Directory
    outputSource:  functional_annotation/pathways_systems_folder_antismash_summary

 # << pathways and systems from antismash >>
  pathways_systems_folder_antismash:
    type: Directory
    outputSource: antismash/antismash_folder

 # << sequence categorisation >>
  sequence-categorisation_folder:                   # [2]
    type: Directory
    outputSource: move_to_seq_cat_folder/out
  rna-count:
    type: File
    outputSource: rna_prediction/LSU-SSU-count

 # << taxonomy summary >>
  taxonomy-summary_folder:
    type: Directory
    outputSource: return_tax_dir/out

 # FAA count
  count_CDS:
    type: int
    outputSource: accessioning_and_prediction/count_faa

  optional_tax_file_flag:
    type: File?
    outputSource: no_tax_file_flag/created_file

  proteinDB_metadata:
    type: File?
    outputSource: accessioning_and_prediction/mgyp_fasta_metadata

  digest_mapfile_for_virify:
    type: File
    outputSource: accessioning_and_prediction/mapfile_for_virify

steps:

# -----------------------------------  << Assign & CGC >>  -----------------------------------
  accessioning_and_prediction:
    in:
      include_protein_assign: include_protein_assign
      filtered_fasta: filtered_fasta
      config_db_file: config_db_file
      study_accession: study_accession
      run_accession: run_accession
      public: public
      CGC_postfixes: CGC_postfixes
      cgc_chunk_size: cgc_chunk_size
      fgs_train: fgs_train
      genecaller_order: genecaller_order
      generate_map_file_flag: generate_map_file_flag
    out:
      - assigned_contigs
      - predicted_proteins
      - predicted_seq
      - count_faa
      - mgyp_fasta_metadata
      - mapfile_for_virify
    run: ../../subworkflows/assembly/accessioning-prediction_subwf.cwl

# -----------------------------------  << RNA PREDICTION >>  -----------------------------------
  rna_prediction:
    in:
      type: { default: 'assembly'}
      input_sequences:
        source:
          - accessioning_and_prediction/assigned_contigs
          - filtered_fasta
        pickValue: first_non_null
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
      pattern_5.8S: 5.8s_pattern
    out:
      - ncRNA
      - cmsearch_result
      - SSU_folder
      - LSU_folder
      - LSU-SSU-count
      - SSU_fasta
      - LSU_fasta
      - compressed_rnas
      - number_LSU_mapseq
      - number_SSU_mapseq
    run: ../../subworkflows/rna_prediction-sub-wf.cwl

# ------------------------- << OTHER ncrnas >> -------------------------
  other_ncrnas:
    run: ../../subworkflows/other_ncrnas.cwl
    in:
     input_sequences:
       source:
         - accessioning_and_prediction/assigned_contigs
         - filtered_fasta
       pickValue: first_non_null
     cmsearch_file: rna_prediction/ncRNA
     other_ncRNA_ribosomal_models: other_ncrna_models
     name_string: { default: 'other_ncrna' }
    out: [ ncrnas ]

# ------------------------- <<ANTISMASH >> -------------------------------

  antismash:
    run: ../../subworkflows/assembly/antismash/main_antismash_subwf.cwl
    in:
      input_filtered_fasta:
        source:
          - accessioning_and_prediction/assigned_contigs
          - filtered_fasta
        pickValue: first_non_null
      clusters_glossary: clusters_glossary
      final_folder_name: { default: pathways-systems }
    out:
      - antismash_folder
      - antismash_clusters

# -----------------------------------  << STEP FUNCTIONAL ANNOTATION >>  -----------------------------------
# - GFF generation
# - DIAMOND
# - KEGG PATHWAYS
# - GENOME PROPERTIES
# - make PATHWAYS-SYSTEMS folder
# - move PATHWAYS-SYSTEMS antismash summary

  functional_annotation:
    run: ../../subworkflows/assembly/Func_ann_and_post_processing-subwf.cwl
    in:
      filtered_fasta:
        source:
          - accessioning_and_prediction/assigned_contigs
          - filtered_fasta
        pickValue: first_non_null
      cgc_results_faa: accessioning_and_prediction/predicted_proteins
      rna_prediction_ncRNA: rna_prediction/ncRNA

      protein_chunk_size_eggnog: protein_chunk_size_eggnog
      EggNOG_db: EggNOG_db
      EggNOG_diamond_db: EggNOG_diamond_db
      EggNOG_data_dir: EggNOG_data_dir

      protein_chunk_size_hmm: protein_chunk_size_hmm
      func_ann_names_hmmer: func_ann_names_hmmer
      HMM_gathering_bit_score: HMM_gathering_bit_score
      HMM_omit_alignment: HMM_omit_alignment
      HMM_database: HMM_database
      HMM_database_dir: HMM_database_dir
      hmmsearch_header: hmmsearch_header

      protein_chunk_size_IPS: protein_chunk_size_IPS
      func_ann_names_ips: func_ann_names_ips
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
      ips_header: ips_header

      diamond_maxTargetSeqs: diamond_maxTargetSeqs
      diamond_databaseFile: diamond_databaseFile
      Uniref90_db_txt: Uniref90_db_txt
      diamond_header: diamond_header

      antismash_geneclusters_txt: antismash/antismash_clusters
      go_config: go_config

      ko_file: ko_file
      graphs: graphs
      pathways_names: pathways_names
      pathways_classes: pathways_classes

      gp_flatfiles_path: gp_flatfiles_path
    out:
      - functional_annotation_folder
      - stats
      - pathways_systems_folder_antismash_summary
      - pathways_systems_folder

# ----------------------------------- << FINAL STEPS ROOT FOLDER >> -----------------------------------

# index FASTA
  fasta_index:
    run: ../../../tools/Assembly/index_fasta/fasta_index.cwl
    in:
      fasta:
        source:
          - accessioning_and_prediction/assigned_contigs
          - filtered_fasta
        pickValue: first_non_null
    out: [fasta_index, fasta_bgz, bgz_index]

# chunking
  chunking_final:
    run: ../../subworkflows/final_chunking.cwl
    in:
      fasta:
        source:
          - accessioning_and_prediction/assigned_contigs
          - filtered_fasta
        pickValue: first_non_null
      ffn: accessioning_and_prediction/predicted_seq
      faa: accessioning_and_prediction/predicted_proteins
      LSU: rna_prediction/LSU_fasta
      SSU: rna_prediction/SSU_fasta
    out:
      - fasta_chunks                         # fasta, ffn, faa, .chunks-files
      - SC_fasta_chunks                                 # LSU, SSU

# gzip
  compression:
    run: ../../../utils/pigz/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source:
          - rna_prediction/ncRNA                        # cmsearch.all.deoverlapped
          - rna_prediction/cmsearch_result              # cmsearch.all
        linkMerge: merge_flattened
    out: [compressed_file]

# add no-tax file-flag if there are no lsu and ssu seqs
  no_tax_file_flag:
    when: $(inputs.count_lsu < 3 && inputs.count_ssu < 3)
    run: ../../../utils/touch_file.cwl
    in:
      count_lsu: rna_prediction/number_LSU_mapseq
      count_ssu: rna_prediction/number_SSU_mapseq
      filename: { default: no-tax}
    out: [ created_file ]

# ----------------------------------- << SEQUENCE CATEGORISATION FOLDER >> -----------------------------------
# << move chunked files >>
  move_to_seq_cat_folder:  # LSU and SSU
    run: ../../../utils/return_directory/return_directory.cwl
    in:
      file_list:
        source:
          - chunking_final/SC_fasta_chunks
          - rna_prediction/compressed_rnas
          - other_ncrnas/ncrnas
        linkMerge: merge_flattened
      dir_name: { default: 'sequence-categorisation' }
    out: [ out ]

# return taxonomy-summary
  return_tax_dir:
    run: ../../../utils/return_directory/return_directory.cwl
    in:
      dir_list:
        - rna_prediction/SSU_folder
        - rna_prediction/LSU_folder
      dir_name: { default: 'taxonomy-summary' }
    out: [out]


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
