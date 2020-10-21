class: Workflow
cwlVersion: v1.0

requirements:
#  - class: SchemaDefRequirement
#    types:
#      - $import: ../tools/Diamond/Diamond-strand_values.yaml
#      - $import: ../tools/Diamond/Diamond-output_formats.yaml
#      - $import: ../tools/InterProScan/InterProScan-apps.yaml
#      - $import: ../tools/InterProScan/InterProScan-protein_formats.yaml
  - class: ResourceRequirement
    ramMin: 20000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
    contigs: File
    contig_min_length: int

outputs:

  qc-status:                                                 # [1]
    type: File
    outputSource: QC-FLAG/qc-flag
  qc_summary:                                                # [1]
    type: File
    outputSource: length_filter/stats_summary_file

 # << qc-statistics >>
  qc-statistics_folder:                                      # [8]
    type: Directory
    outputSource: qc_stats/output_dir

 # fasta
  filtered_fasta:
    type: File
    outputSource: length_filter/filtered_file

 # hashsum file
  hashsum_input:
    type: File
    outputSource: hashsum/hashsum

steps:

# << calculate hashsum >>
  hashsum:
    run: ../../../utils/generate_checksum/generate_checksum.cwl
    in:
      input_file: contigs
    out: [ hashsum ]

# << unzip contig file >>
  unzip:
    in:
      target_reads: contigs
      assembly: {default: true}
    out: [unzipped_file]
    run: ../../../utils/multiple-gunzip.cwl

# << count reads pre QC >>
  count_reads:
    in:
      sequences: unzip/unzipped_file
      number: { default: 1 }
    out: [ count ]
    run: ../../../utils/count_fasta.cwl

# <<clean fasta headers??>>
  clean_headers:
    in:
      sequences: unzip/unzipped_file
    out: [ sequences_with_cleaned_headers ]
    run: ../../../utils/clean_fasta_headers.cwl
    label: "removes spaces in some headers"

# << Length QC >>
  length_filter:
    in:
      seq_file: clean_headers/sequences_with_cleaned_headers
      min_length: contig_min_length
      submitted_seq_count: count_reads/count
      stats_file_name: { default: 'qc_summary' }
      input_file_format: { default: fasta }
    out: [filtered_file, stats_summary_file]
    run: ../../../tools/qc-filtering/qc-filtering.cwl

# << count processed reads >>
  count_processed_reads:
    in:
      sequences: length_filter/filtered_file
      number: { default: 1 }
    out: [ count ]
    run: ../../../utils/count_fasta.cwl

# << QC FLAG >>
  QC-FLAG:
    run: ../../../utils/qc-flag.cwl
    in:
      qc_count: count_processed_reads/count
    out: [ qc-flag ]

# << QC stats >>
  qc_stats:
    in:
      QCed_reads: length_filter/filtered_file
      sequence_count: count_processed_reads/count
    out: [ output_dir, summary_out ]
    run: ../../../tools/qc-stats/qc-stats.cwl


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
