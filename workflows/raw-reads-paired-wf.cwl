cwlVersion: v1.0
class: Workflow
label: Raw Reads pipeline paired

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../tools/biom-convert/biom-convert-table.yaml

inputs:
  forward_reads:
    type: File
    format: edam:format_1930  # FASTQ
  reverse_reads:
    type: File
    format: edam:format_1930  # FASTQ

  ssu_db: {type: File, secondaryFiles: [.mscluster] }
  lsu_db: {type: File, secondaryFiles: [.mscluster] }
  ssu_tax: File
  lsu_tax: File
  ssu_otus: File
  lsu_otus: File
  rfam_models: File[]
  rfam_model_clans: File
  ssu_label: string
  su_label: string

  other_rfam_models: File[]
  other_rfam_clans: File
  #REMOVE
  Script: File

  InterProScan_applications_in: ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
  InterProScan_outputFormat_in: ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
  InterProScan_databases_in: Directory
  go_summary_config: File
  HMMSCAN_gathering_bit_score_in: boolean
  HMMSCAN_omit_alignment_in: boolean
  HMMSCAN_name_database_in: string
  HMMSCAN_data_in: Directory
  EggNOG_db:
  EggNOG_diamond_db:
  EggNOG_data_dir:

outputs:
  motus_biom:
    type: File
    outputSource: mOTUs/motus_biom
  motus_tsv:
    type: File
    outputSource: mOTUs/motus_tsv

  processed_nucleotide_reads:
    type: File
    outputSource: trim_and_reformat_reads/trimmed_and_reformatted_reads

  qc_stats_summary:
    type: File
    outputSource: generate_qc_stats/summary_out
  qc_stats_seq_len_pbcbin:
    type: File
    outputSource: generate_qc_stats/seq_length_pcbin
  qc_stats_seq_len_bin:
    type: File
    outputSource: generate_qc_stats/seq_length_bin
  qc_stats_seq_len:
    type: File
    outputSource: generate_qc_stats/seq_length_out
  qc_stats_nuc_dist:
    type: File
    outputSource: generate_qc_stats/nucleotide_distribution_out
  qc_stats_gc_pcbin:
    type: File
    outputSource: generate_qc_stats/gc_sum_pcbin
  qc_stats_gc_bin:
    type: File
    outputSource: generate_qc_stats/gc_sum_bin
  qc_stats_gc:
    type: File
    outputSource: generate_qc_stats/gc_sum_out

  ncRNAs:
    type: File
    outputSource: identify_ncrna/ncRNAs
  5s_fasta:
    type: File
    outputSource: identify_ncrna/5S_fasta
  SSU_fasta:
    type: File
    outputSource: identify_ncrna/SSU_fasta
  LSU_fasta:
    type: File
    outputSource: identify_ncrna/LSU_fasta
  SSU_coords:
    type: File
    outputSource: identify_ncrna/SSU_coords
  LSU_coords:
    type: File
    outputSource: identify_ncrna/LSU_coords
  SSU_classifications:
    type: File
    outputSource: identify_ncrna/SSU_classifications
  SSU_otu_tsv:
    type: File
    outputSource: identify_ncrna/SSU_otu_tsv
  SSU_otu_txt:
    type: File
    outputSource: identify_ncrna/SSU_otu_txt
  SSU_krona_image:
    type: File
    outputSource: identify_ncrna/SSU_krona_image
  LSU_classifications:
    type: File
    outputSource: identify_ncrna/LSU_classifications
  LSU_otu_tsv:
    type: File
    outputSource: identify_ncrna/LSU_otu_tsv
  LSU_otu_txt:
    type: File
    outputSource: identify_ncrna/LSU_otu_txt
  LSU_krona_image:
    type: File
    outputSource: identify_ncrna/LSU_krona_image
  ssu_hdf5_classifications:
    type: File
    outputSource: identify_ncrnay/ssu_hdf5_classifications
  ssu_json_classifications:
    type: File
    outputSource: identify_ncrnay/ssu_json_classifications
  lsu_hdf5_classifications:
    type: File
    outputSource: identify_ncrna/lsu_hdf5_classifications
  lsu_json_classifications:
    type: File
    outputSource: identify_ncrna/lsu_json_classifications

  other_ncrnas_seqs:
    type:
        type: array
        items: File
    outputSource: other_ncrnas/ncrnas

  CDS_aa:
    type: File
    outputSource: combine_CDS_aa/result
  CDS_nucl:
    type: File
    outputSource: combine_CDS_nucl/result
  #orfstats_output?

  IPR_hits:
    type: File
    outputSource: combine_interpro/result
  GO_summary:
    type: File
    outputSource: summarize_with_GO/go_summary
  GO_summary_slim:
    type: File
    outputSource: summarize_with_GO/go_summary_slim
  pfam_annotations:
    type: File
    outputSource: pfam_parse/pfam_annotations
  pfam_frequency:
    type: File
    outputSource: pfam_parse/pfam_summary
  #ipr_stats?

  hmmscan_table:
    type: File
    outputSource: tab_modification/output_with_tabs
  kegg_orthologs:
    type: File
    outputSource: hmm_stats/output_table

steps:

  overlap_reads:
    label: Merge paired reads with overlap into single reads
    run: ../tools/SeqPrep/seqprep.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]

  combine_overlapped_and_unmerged_reads:
    label: Merge the outputs of SeqPrep (merged reads, forward and reverse unmerged reads) into a single file
    run: ../tools/SeqPrep/seqprep-merge.cwl
    in: 
      merged_reads: overlap_reads/merged_reads
      forward_unmerged_reads: overlap_reads/forward_unmerged_reads
      reverse_unmerged_reads: overlap_reads/reverse_unmerged_reads
    out: [ merged_with_unmerged_reads ]

  mOTUs:
    run: mOTUs-workflow.cwl
    in:
      merged_reads: combine_overlapped_and_unmerged_reads/merged_with_unmerged_reads
    out: [ motus_biom, motus_tsv ]

  trim_and_reformat_reads:
    label: Trim and reformat reads
    run: trim_and_reformat_reads.cwl
    in:
      reads: combine_overlapped_and_unmerged_reads/merged_with_unmerged_reads
    out:  [ trimmed_and_reformatted_reads ]

  generate_qc_stats:
    label: Generate some post quality control statistics
    run: ../tools/qc-stats/qc-stats.cwl
    in:
      QCed_reads: trim_and_reformat_reads/trimmed_and_reformatted_reads
    out:
      - summary_out
      - seq_length_pcbin
      - seq_length_bin
      - seq_length_out
      - nucleotide_distribution_out
      - gc_sum_pcbin
      - gc_sum_bin
      - gc_sum_out

  identify_ncrna:
    run: rna_prediction.cwl
    in:
       input_sequences: trim_and_reformat_reads/trimmed_and_reformatted_reads
       silva_ssu_database: ssu_db
       silva_lsu_database: lsu_db
       silva_ssu_taxonomy: ssu_tax
       silva_lsu_taxonomy: lsu_tax
       silva_ssu_otus: ssu_otus
       silva_lsu_otus: lsu_otus
       ncRNA_ribosomal_models: rfam_models
       ncRNA_ribosomal_model_clans: rfam_model_clans
       otu_ssu_label: ssu_label
       otu_lsu_label: lsu_label
    out:
      - ncRNAs
      - 5S_fasta
      - SSU_fasta
      - LSU_fasta
      - SSU_coords
      - LSU_coords
      - SSU_classifications
      - SSU_otu_tsv
      - SSU_otu_txt
      - SSU_krona_image
      - LSU_classifications
      - LSU_otu_tsv
      - LSU_otu_txt
      - LSU_krona_image
      - ssu_hdf5_classifications
      - ssu_json_classifications
      - lsu_hdf5_classifications
      - lsu_json_classifications

  other_ncrnas:
    run: ../tools/RNA_prediction/other_ncrnas.cwl
    in:
      indexed_sequences: trim_and_reformat_reads/trimmed_and_reformatted_reads
      other_ncRNA_ribosomal_models: other_rfam_models
      other_ncRNA_ribosomal_model_clans: other_rfam_clans
      #REMOVE
      script: Script
    out: [ ncrnas ]

  split_seqs:
    run: ../tools/fasta_chunker.cwl
    in:
      seqs: trim_and_reformat_reads/trimmed_and_reformatted_reads
      chunk_size: { default: 100000 }
    out: [ chunks ]

  functional_annotation:
    run: functional_annotation.cwl
    scatter: sequences
    in:
      sequences: split_seqs/chunks
      cmsearch: identify_ncrna/ncRNAs
      InterProScan_applications: InterProScan_applications_in
      InterProScan_outputFormat: InterProScan_outputFormat_in
      InterProScan_databases: InterProScan_databases_in
      HMMSCAN_gathering_bit_score: HMMSCAN_gathering_bit_score_in
      HMMSCAN_omit_alignment: HMMSCAN_omit_alignment_in
      HMMSCAN_name_database: HMMSCAN_name_database_in
      HMMSCAN_data: HMMSCAN_data_in
      EggNOG_db:
      EggNOG_diamond_db:
      EggNOG_data_dir:
    out:
      - CGC_predicted_proteins
      - CGC_predicted_seq
      - InterProScan_I5
      - hmmscan_table
#      - eggnog_output

  # Combined gene caller #
  combine_CDS_aa:
    run: ../utils/concatenate.cwl
    in:
      files: functional_annotation/CGC_predicted_proteins
    out: [ result ]
    label: "CDS - amino acid sequence"

  combine_CDS_nucl:
    run: ../utils/concatenate.cwl
    in:
      files: functional_annotation/CGC_predicted_seq
    out: [ result ]
    label: "CDS - nucleotide sequences"

#  orf_stats:
#    run: ../tools/functional_stats/orf_stats.cwl
#    in:
#      orfs: combine_CDS_aa/result
#    out: [ numberReadsWithOrf, numberOrfs, readsWithOrf ]
#    label: "two integers and list of accession numbers with CDS"

  # interpro #
  combine_interpro:
    run: ../utils/concatenate.cwl
    in:
      files: functional_annotation/InterProScan_I5
    out: [ result ]
    label: "combine all chunked interpro outputs to 1 tsv"

  summarize_with_GO:
    doc: |
      A summary of Gene Ontology (GO) terms derived from InterPro matches to
      the sample. It is generated using a reduced list of GO terms called
      GO slim (http://www.geneontology.org/ontology/subsets/goslim_metagenomics.obo)
    run: ../tools/GO-slim/go_summary.cwl
    in:
      InterProScan_results: combine_interpro/result
      config: go_summary_config
    out: [ go_summary, go_summary_slim ]

  pfam_parse:
    run: ../tools/Pfam-Parse/pfam_workflow.cwl
    in:
      interpro_file: combine_interpro/result
    out: [pfam_annotations, pfam_summary]
    label: "parse interpro output for pfam hits"

#  ipr_stats:
#    run: ../tools/functional_stats/ipr_stats.cwl
#    in:
#      iprscan: combine_interpro/results
#    out:
#      - match_count
#      - CDS_with_match_count
#      - reads_with_match_count
#      - reads
#      - id_list

  # hmmscan #
  combine_hmm:
    run: ../utils/concatenate.cwl
    in:
      files: functional_annotation/hmmscan_table
    out: [ result ]
    label "combined chunked hmmscam outputs"

  tab_modification:
    run: ../tools/KEGG_analysis/Modification/modification_table.cwl
    in:
      input_table: combine_hmm/result
    out: [ output_with_tabs ]
    label: "change spaced file to tsv"

  hmm_stats:
    run: ../tools/KEGG_analysis/Parsing_hmmscan/parsing_hmmscan.cwl
    in:
      table: tab_modification/output_with_tabs
    out: [ stdout, stderr, output_table ]
    label: "output file of KO families and contigs"

  # eggnog #
#  combine_eggnong:
#    run: ../utils/concatenate.cwl
#    in:
#      files: functional_annotation/eggnog_out
#    out: [ result ]
#    label "combined eggnog output"

#   eggnog_stats:

#  create_fasta_files:
#    run: ../tools/functional_stats/create_categorisations.cwl
#    in:
#    out:

#generate summary stats

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
