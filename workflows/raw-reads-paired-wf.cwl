cwlVersion: v1.0
class: Workflow
label: MGnify pipeline v5.0 (paired end version)

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

  #Rfam models for ribosomal subunits and other ubiquitous ncRNAs
  covariance_models: File[]
  clanInfoFile: File
  cmsearchCores: int
  
outputs: #NEEDS UPDATING
  processed_nucleotide_reads:
    type: File
    outputSource: trim_and_reformat_reads/trimmed_and_reformatted_reads

  deoverlapped_matches:
    type: File
    outputSource: identify_nc_rna/deoverlapped_matches
 
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

  trim_and_reformat_reads:
    label: Trim and reformat reads
    run: trim_and_reformat_reads.cwl
    in:
      reads: combine_overlaped_and_unmerged_reads/merged_with_unmerged_reads
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
      - SSU_krona_image
      - LSU_classifications
      - LSU_otu_tsv
      - LSU_krona_image
      - ssu_hdf5_classifications
      - ssu_json_classifications
      - lsu_hdf5_classifications
      - lsu_json_classifications

  split_seqs:
    run: ../tools/fasta_chunker.cwl
    in:
      seqs: trim_and_reformat_reads/trimmed_and_reformatted_reads
      chunk_size: { default: 100000 }
    out: [ chunks ]

  combined_gene_caller:
    run: ../tools/Combined_gene_caller/combined_gene_caller.cwl
    scatter: input_fasta
    in:
      input_fasta: split_seqs/chunks
      seq_type: { default: "s" }
      maskfile: identify_ncrna/ncRNAs
    out:
      - predicted_proteins
      - predicted_seq
      - gene_caller_out
      - stderr
      - stdout
    label: "predictions of FragGeneScan with faselector

  combine_CDS_aa:
    run: ../utils/concatenate.cwl
    in:
      files: orf_prediction/aa_CDS
    out: [ result ]
    label: "CDS - amino acid sequence"

  combine_CDS_nucl:
    run: ../utils/concatenate.cwl
    in:
      files: orf_prediction/nuc_CDS
    out: [ result ]
    label: "CDS - nucleotide sequences"

  orf_stats:
    run: ../tools/functional_stats/orf_stats.cwl
    in:
      #input can be nucleotide or amino acid seqs. accessions should be the same.
      orfs: combine_CDS_aa/result
    out: [ numberReadsWithOrf, numberOrfs, readsWithOrf ]
    label: "two integers and list of accession numbers with CDS"

  interproscan:
    run: ../tools/InterProScan/InterProScan-v5.cwl
    scatter: inputFile
    in:
      applications: InterProScan_applications
      inputFile: combined_gene_caller/predicted_proteins
      outputFormat: InterProScan_outputFormat
      databases: InterProScan_databases
    out: [i5Annotations]
    label: "InterProScan: protein sequence classifier"

  combine_interpro:
    run: ../utils/concatenate.cwl
    in:
      files: interproscan/i5Annotations
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

  ipr_stats:
    run: ../tools/functional_stats/ipr_stats.cwl
    in:
      iprscan: combine_interpro/results
    out:
      - match_count
      - CDS_with_match_count
      - reads_with_match_count
      - reads
      - id_list

  categorisation:
    run: ../tools/create_categorisations.cwl
    in:
      seqs: extract_SSUs/sequences
      ipr_idset: ipr_stats/reads
      cds_idset: orf_stats/readsWithOrf
    out: [ interproscan, pCDS_seqs, no_functions_seqs ]

  hmmscan:
    run: ../tools/hmmscan/hmmscan.cwl
    scatter: seqfile
    in:
      seqfile: combined_gene_caller/predicted_proteins
      gathering_bit_score: HMMSCAN_gathering_bit_score
      name_database: HMMSCAN_name_database
      data: HMMSCAN_data
      omit_alignment: HMMSCAN_omit_alignment
    out: [ output_table ]
    label: "Analysis using profile HMM on db"

  combine_hmm:
    run: ../utils/concatenate.cwl
    in:
      files: hmmscan/output_table
    out: [ result ]
    label "combined chunked hmmscam outputs"

  tab_modification:
    run: ../tools/KEGG_analysis/Modification/modification_table.cwl
    in:
      input_table: combine_hmm/result
    out: [ output_with_tabs ]
    label: "change spaced file to tsv"

  hmm_stats:
    run: ../tools/KEGG_analysis/Parsing_hmmscan
    in:
      table: tab_modification/output_with_tabs
    out: [ stdout, stderr, output_table ]
    label: "output file of KO families and contigs"

  eggnong:
    run: ../tools/EggNOG/eggNOG/eggnong.cwl
    scatter: fasta_file
    in:
      fasta_file: combined_gene_caller/predicted_proteins
    out: [ stdout, stderr, output_annotations, output_orthologs ]

  create_fasta_files:
    run: ../tools/functional_stats/create_categorisations.cwl
    in:
    out:

  #run Eggnogg
  #Eggnog stats

#run create categorisations cwl x2 for nucleotide and
  get_nucl_seqfiles:
    run: ../

#generate summary stats

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
