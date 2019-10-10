class: Workflow
cwlVersion: v1.0

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
$schemas:
  - 'http://edamontology.org/EDAM_1.20.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'

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

steps:

  # << unzip contig file >>
  unzip:
    in:
      forward_unmerged_reads: contigs
    out: [unzipped_merged_reads]
    run: ../tools/Seqprep/seqprep-merge.cwl

  # << count reads pre QC >>
  count_reads:
    in:
      sequences: unzip/unzipped_merged_reads
    out: [ count ]
    run: ../utils/count_fasta.cwl

  # << Length QC >>
  length_filter:
    in:
      seq_file: unzip/unzipped_merged_reads
      min_length: contig_length
      submitted_seq_count: count_reads/count
      stats_file_name: ?
    out: [filtered_file, stats_summary_file]
    run: ../tools/qc-filtering/qc-filtering.cwl

  # << QC stats >>
  sequence_stats:
    in:
      QCed_reads: contigs
    out:
      - summary_out
      - seq_length_pcbin
      - seq_length_bin
      - seq_length_out
      - nucleotide_distribution_out
      - gc_sum_pcbin
      - gc_sum_bin
      - gc_sum_out
    run: ../tools/qc-stats/qc-stats.cwl

  # << RNA prediction >>
  rna_prediction:
    in:
      input_sequences: contigs
      silva_ssu_database: rna_pred_silva_ssu_database
      silva_lsu_database: rna_pred_silva_lsu_database
      silva_ssu_taxonomy: rna_pred_silva_ssu_taxonomy
      silva_lsu_taxonomy: rna_pred_silva_lsu_taxonomy
      silva_ssu_otus: rna_pred_silva_ssu_otus
      silva_lsu_otus: rna_pred_silva_lsu_otus
      ncRNA_ribosomal_models: rna_pred_ncRNA_ribosomal_models
      ncRNA_ribosomal_model_clans: rna_pred_ncRNA_ribosomal_model_clans
      otu_ssu_label: rna_pred_otu_ssu_label
      otu_lsu_label: rna_pred_otu_lsu_label
    out:
      - ncRNAs
      - 5S_fasta
      - SSU_fasta
      - LSU_fasta
      - SSU_classifications
      - SSU_otu_tsv
      - SSU_krona_image
      - LSU_classifications
      - LSU_otu_tsv
      - LSU_krona_image
      - ssu_hdf5_classifications
      - ssu_json_classifications
      - lsu_hdf5_classifications
      - lsu_json_classifications
    run: rna_prediction.cwl

  # << Chunk fasta >>
    split_seqs:
    in:
      seqs: length_filter/filtered_file
      chunk_size: { default: 100000 }
    out: [ chunks ]
    run: ../tools/fasta_chunker.cwl

  # << CombinedGeneCaller >>
  combined_gene_caller:
    scatter: input_fasta
    in:
      input_fasta: split_seqs/chunks
      seq_type: CGC_seq_type
      maskfile: rna_prediction/ncRNAs
      config: cgc_config
      outdir: cgc_outdir
    out:
      - predicted_proteins
      - predicted_seq
      - stderr
      - stdout
    run: ../tools/Combined_gene_caller/combined_gene_caller.cwl
    label: "combine predictions of FragGeneScan and Prodigal with faselector"

  # << combine CGC chunks >>
  combine_cgc_proteins:
    in:
      files: combined_gene_caller/predicted_proteins
      outputFileName: { default : 'faa_united' }
    out: [result]
    label: "combined CGC protein output"

  combine_cgc_nucleotides:
    in:
      files: combined_gene_caller/predicted_seq
      outputFileName: { default: 'ffn_united' }
    out: [result]
    label: "combined CGC nucleotide output"

  # << Functional annotation. InterProScan >>
  interproscan:
    in:
      applications: InterProScan_applications
      inputFile: combined_gene_caller/predicted_proteins
      outputFormat: InterProScan_outputFormat
      databases: InterProScan_databases
    out:
      - i5Annotations
    run: ../tools/InterProScan/InterProScan-v5.cwl
    label: "InterProScan: protein sequence classifier"

  # << Functional annotation. KEGG >>
  #hmmscan:
  #  in:
  #    seqfile: combined_gene_caller/predicted_proteins
  #    gathering_bit_score: HMMSCAN_gathering_bit_score
  #    name_database: HMMSCAN_name_database
  #    data: HMMSCAN_data
  #    omit_alignment: HMMSCAN_omit_alignment
  #  out:
  #    - output_table
  #  run: ../tools/hmmscan/hmmscan.cwl
  #  label: "Analysis using profile HMM on db"

  # << Functional annotation. COGs >>
  # make db
  # run EggNOG

  # << Functional annotation -- Results. GO-slim >>
  summarize_with_GO:
    doc: |
      A summary of Gene Ontology (GO) terms derived from InterPro matches to
      the sample. It is generated using a reduced list of GO terms called
      GO slim (http://www.geneontology.org/ontology/subsets/goslim_metagenomics.obo)
    run: ../tools/GO-slim/go_summary.cwl
    in:
      InterProScan_results: interproscan/i5Annotations
      config: go_summary_config
    out: [ go_summary, go_summary_slim ]

  # << Functional annotation -- Results. Pfam parsing >>
  pfam_parse:
    in:
      interpro_file: interproscan/i5Annotations
    out:
      - pfam_annotations
      - pfam_summary
    run: ../tools/Pfam-Parse/pfam_workflow.cwl

  # << Systems. Genome Properties >>
  genome_properties:
    in:
      input_tsv_file: interproscan/i5Annotations
    out:
      - json
      - table
      - stderr
      - stdout
    run: ../tools/Genome_properties/genome_properties.cwl
    label: "Preparing summary file for genome properties"

  # << Systems. Pathways >>
  #kegg_analysis:
  #  in:
  #    input_table_hmmscan: hmmscan/output_table
  #  out:
  #    - modification_out
  #    - parsing_hmmscan_out
  #    - kegg_pathways_summary
  #    - kegg_pathways_matching
  #    - kegg_pathways_missing
  #    - kegg_contigs
  #    - kegg_stdout
  #  run: kegg_analysis.cwl

  # << Systems. Antismash >>
  antismash:
    in:
      input_fasta: contigs
    out:
      - output_files
    run: ../tools/antismash/antismash.cwl
    label: "analysis of secondary metabolite biosynthesis gene clusters in bacterial and fungal genomes"

  # << Diamond >>
  diamond_blastp:
    in:
      databaseFile: Diamond_databaseFile
      outputFormat: Diamond_outFormat
      queryInputFile: combined_gene_caller/predicted_proteins
      maxTargetSeqs: Diamond_maxTargetSeqs
    out:
      - matches
    run: ../tools/Diamond/Diamond.blastp-v0.9.21.cwl
    label: "align DNA query sequences against a protein reference UniRef90 database"

  # << Diamond post-processing >>
  diamond_post_processing:
    in:
      input_diamond: diamond_blastp/matches
      input_db: Diamond_postProcessingDB
    out:
      - join_out
    run: ../tools/Diamond-Post-Processing/postprocessing_pipeline.cwl
    label: "add additional annotation to diamond matches"

  # << Viral >>
  #viral_pipeline:
  #  in:
  #    assembly: contigs
  #    predicted_proteins: combined_gene_caller/predicted_proteins
  #    hmmscan_gathering_bit_score: viral_hmmscan_gathering_bit_score
  #    hmmscan_omit_alignment: viral_hmmscan_omit_alignment
  #    hmmscan_name_database: viral_hmmscan_name_database
  #    hmmscan_folder_db: viral_hmmscan_folder_db
  #    hmmscan_filter_e_value: viral_hmmscan_filter_e_value
  #  out:
  #    - output_parsing
  #    - output_final_mapping
  #    - output_final_assign
  #  run: viral_pipeline.cwl
  #  label: "detecting and processing viral sequences"