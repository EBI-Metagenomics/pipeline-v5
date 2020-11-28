class: Workflow
cwlVersion: v1.2.0-dev4

requirements:
  - class: ResourceRequirement
    ramMin: 20000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  filtered_fasta: File
  cgc_results_faa: File
  rna_prediction_ncRNA: File

  protein_chunk_size_eggnog:  int
  EggNOG_db: string
  EggNOG_diamond_db: string
  EggNOG_data_dir: string

  protein_chunk_size_hmm: int
  func_ann_names_hmmer: string
  HMM_gathering_bit_score: boolean
  HMM_omit_alignment: boolean
  HMM_name_database: string
  hmmscan_header: string

  protein_chunk_size_IPS: int
  func_ann_names_ips: string
  InterProScan_databases: string
  InterProScan_applications: string[]
  InterProScan_outputFormat: string[]
  ips_header: string

  diamond_maxTargetSeqs: int
  diamond_databaseFile: string
  Uniref90_db_txt: string
  diamond_header: string

  antismash_geneclusters_txt: File
  go_config: string

  ko_file: string
  graphs: string
  pathways_names: string
  pathways_classes: string

  gp_flatfiles_path: string

outputs:

 # << functional annotation >>
  functional_annotation_folder:                              # [15]
    type: Directory?
    outputSource: folder_functional_annotation/functional_annotation_folder
  stats:                                                     # [6]
    outputSource: folder_functional_annotation/stats
    type: Directory?

  pathways_systems_folder_antismash_summary:
    type: Directory?
    outputSource:  move_antismash_summary_to_pathways_systems_folder/summary_in_folder
  pathways_systems_folder:
    type: Directory?
    outputSource: move_to_pathways_systems_folder/out

steps:
# -----------------------------------  << STEP FUNCTIONAL ANNOTATION >>  -----------------------------------
  functional_annotation:
    run: ../../subworkflows/assembly/functional_annotation.cwl
    in:
      CGC_predicted_proteins: cgc_results_faa
      chunk_size_eggnog: protein_chunk_size_eggnog
      chunk_size_hmm: protein_chunk_size_hmm
      chunk_size_IPS: protein_chunk_size_IPS
      name_ips: func_ann_names_ips
      name_hmmer: func_ann_names_hmmer
      HMM_gathering_bit_score: HMM_gathering_bit_score
      HMM_omit_alignment: HMM_omit_alignment
      HMM_database: HMM_name_database
      EggNOG_db: EggNOG_db
      EggNOG_diamond_db: EggNOG_diamond_db
      EggNOG_data_dir: EggNOG_data_dir
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
    out: [ hmm_result, ips_result, eggnog_annotations, eggnog_orthologs ]

# -----------------------------------  << STEP GFF >>  -----------------------------------
  gff:
    run: ../../../tools/Assembly/GFF/gff_generation.cwl
    in:
      ips_results: functional_annotation/ips_result
      eggnog_results: functional_annotation/eggnog_annotations
      input_faa: cgc_results_faa
      output_name:
        source: filtered_fasta
        valueFrom: $(self.nameroot).annotations.gff
    out: [ output_gff_gz, output_gff_index ]

# -----------------------------------  << FUNCTIONAL ANNOTATION FOLDER >>  -----------------------------------
# << DIAMOND >>
  diamond:
    run: ../../../tools/Assembly/Diamond/diamond-subwf.cwl
    in:
      queryInputFile: cgc_results_faa
      outputFormat: { default: '6' }
      maxTargetSeqs: diamond_maxTargetSeqs
      strand: { default: 'both'}
      databaseFile: diamond_databaseFile
      threads: { default: 32 }
      Uniref90_db_txt: Uniref90_db_txt
      filename:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
    out: [post-processing_output]

# << collect folder >>
  folder_functional_annotation:
    run: ../../subworkflows/assembly/deal_with_functional_annotation.cwl
    in:
      fasta: filtered_fasta
      IPS_table: functional_annotation/ips_result
      diamond_table: diamond/post-processing_output
      hmmscan_table: functional_annotation/hmm_result
      antismash_geneclusters_txt: antismash_geneclusters_txt
      rna: rna_prediction_ncRNA
      cds: cgc_results_faa
      go_config: go_config
      eggnog_orthologs: functional_annotation/eggnog_orthologs
      eggnog_annotations: functional_annotation/eggnog_annotations
      diamond_header: diamond_header
      hmmscan_header: hmmscan_header
      ips_header: ips_header
      output_gff_gz: gff/output_gff_gz
      output_gff_index: gff/output_gff_index
      ko_file: ko_file
    out: [functional_annotation_folder, stats, summary_antismash]

# ----------------------------------- << PATHWAYS and SYSTEMS >> -----------------------------------
# << KEGG PATHWAYS >>
  pathways:
    run: ../../subworkflows/assembly/kegg_analysis.cwl
    in:
      input_table_hmmscan: functional_annotation/hmm_result
      filtered_fasta: filtered_fasta
      outputname:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
      graphs: graphs
      pathways_names: pathways_names
      pathways_classes: pathways_classes
    out: [ kegg_pathways_summary, kegg_contigs_summary]

# ---------------------- << GENOME PROPERTIES >> ------------------------
  genome_properties:
    run: ../../../tools/Assembly/Genome_properties/genome_properties.cwl
    in:
      input_tsv_file: functional_annotation/ips_result
      flatfiles_path: gp_flatfiles_path
      GP_txt: {default: genomeProperties.txt}
      name:
        source: filtered_fasta
        valueFrom: $(self.nameroot).summary.gprops.tsv
    out: [ summary ]

# << change TSV to CSV >>
  change_formats_and_names:
    run: ../../subworkflows/assembly/change_formats_and_names.cwl
    in:
      genome_properties_summary: genome_properties/summary
      kegg_summary: pathways/kegg_pathways_summary
      fasta: filtered_fasta
    out: [gp_summary_csv, kegg_summary_csv]

# << move PATHWAYS-SYSTEMS >>
  move_to_pathways_systems_folder:
    run: ../../../utils/return_directory/return_directory.cwl
    in:
      file_list:
        source:
          - pathways/kegg_contigs_summary                       # kegg contigs.tsv -- not using
          - change_formats_and_names/kegg_summary_csv           # kegg pathways.csv
          - change_formats_and_names/gp_summary_csv             # genome properties.csv
        linkMerge: merge_flattened
      dir_name: { default: pathways-systems }
    out: [ out ]

# << move PATHWAYS-SYSTEMS antismash summary>>
  move_antismash_summary_to_pathways_systems_folder:
    run: ../../../tools/Assembly/antismash/move_antismash_summary/move_antismash_summary.cwl
    in:
      antismash_summary: folder_functional_annotation/summary_antismash
      folder_name: { default: pathways-systems }
    out: [ summary_in_folder ]