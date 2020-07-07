class: Workflow
cwlVersion: v1.0

label: "WF leaves sequences that length is more than 1000bp, run antismash + gene clusters post-processing, GFF generation"

requirements:
  - class: ResourceRequirement
    ramMin: 5000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:

    input_filtered_fasta: File
    clusters_glossary: File
    final_folder_name: string

outputs:
  antismash_folder:
    type: Directory
    outputSource: antismash/antismash_in_folder
  antismash_clusters:
    type: File?
    outputSource: antismash/reformated_clusters

steps:

# << count reads pre QC >>
  count_reads:
    in:
      sequences: input_filtered_fasta
      number: { default: 1 }
    out: [ count ]
    run: ../../../utils/count_fasta.cwl

  filter_contigs_antismash:
    run: ../../qc-filtering/qc-filtering.cwl
    in:
      seq_file: input_filtered_fasta
      min_length: { default: 1000 }
      submitted_seq_count: count_reads/count
      stats_file_name: { default: 'qc_summary_antismash' }
      input_file_format: { default: fasta }
    out: [filtered_file]

  antismash:
    run: cwl-s/antismash_v4_with_postprocessing.cwl
    in:
      outdirname: {default: 'antismash_result'}
      input_fasta: filter_contigs_antismash/filtered_file
      glossary: clusters_glossary
      outname:
        source: input_filtered_fasta
        valueFrom: $(self.nameroot)
      final_folder: final_folder_name
    out:
      - antismash_in_folder
      - reformated_clusters
      - stderr
      - stdout


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schema.rdf

's:author': 'Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"