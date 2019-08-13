class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  assembly:  # masked reads on .fasta format
    type: File
  predicted_proteins:  # output of Prodigal in .faa format
    type: File
  virsorter_data:
    type: Directory?
    default:
      class: Directory
      path:  ../tools/Viral/VirSorter/virsorter-data
      location: ../tools/Viral/VirSorter/virsorter-data
  hmmscan_gathering_bit_score:
    type: boolean
  hmmscan_omit_alignment:
    type: boolean
  hmmscan_name_database:
    type: string
  hmmscan_folder_db:
    type: Directory
  hmmscan_filter_e_value:
    type: float

outputs:
  output_parsing:
    outputSource: parse_pred_contigs/output_array
    type:
      type: array
      items: Directory
  output_final_mapping:
    outputSource: subworkflow_for_each_confidence_group/output_mapping
    type:
      type: array
      items: Directory
  output_final_assign:
    outputSource: subworkflow_for_each_confidence_group/output_assign
    type:
      type: array
      items: File

steps:

  length_filter:
    in:
      fasta_file: assembly
    out:
      - filtered_contigs_fasta
    run: ../tools/Viral/LengthFiltering/length_filtering.cwl
    label: "Extract sequences at least X kb long (default: X = 5)"

  virfinder:
    in:
      fasta_file: length_filter/filtered_contigs_fasta
    out:
      - output
    run: ../tools/Viral/VirFinder/virfinder.cwl
    label: "VirFinder: R package for identifying viral sequences from metagenomic data using sequence signatures"

  virsorter:
    in:
      data: virsorter_data
      fasta_file: length_filter/filtered_contigs_fasta
    out:
      - predicted_viral_seq_dir
    run: ../tools/Viral/VirSorter/virsorter.cwl
    label: "VirSorter: mining viral signal from microbial genomic data"

  parse_pred_contigs:
    in:
      assembly: length_filter/filtered_contigs_fasta
      virfinder_tsv: virfinder/output
      virsorter_dir: virsorter/predicted_viral_seq_dir
    out:
      - output_array
      - stdout
      - stderr
    run: ../tools/Viral/ParsingPredictions/parse_viral_pred.cwl
    label: "Separate results VS and VF to High, Low confidence groups and Putative prophages"

  subworkflow_for_each_confidence_group:
    in:
      folder_with_names: parse_pred_contigs/output_array
      predicted_proteins: predicted_proteins
      hmmscan_gathering_bit_score: hmmscan_gathering_bit_score
      hmmscan_omit_alignment: hmmscan_omit_alignment
      hmmscan_name_database: hmmscan_name_database
      hmmscan_folder_db: hmmscan_folder_db
      hmmscan_filter_e_value: hmmscan_filter_e_value
    type: float
    out:
      - output_filtration  # takes viral sequences from Prodigal results
      - output_hmmscan  # HMMSCAN predicts annotations for each protein from confidence groups
      - output_hmm_postprocessing  # makes hmmscan result tab-separated with title
      - output_evalue  # generate dataframe that stores the profile alignment ratio and total e-value for each ViPhOG-query pair
      - output_annotation  # generate tabular file with ViPhOG annotation results for proteins predicted in viral contigs
      - output_mapping
      - output_assign
    scatter: folder_with_names
    run: viral_processing_subworkflow.cwl
