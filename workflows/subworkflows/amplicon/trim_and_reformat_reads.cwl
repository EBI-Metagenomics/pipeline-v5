cwlVersion: v1.2.0-dev4
class: Workflow
label: Trim and reformat reads (single and paired end version)

requirements:
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  reads: File

outputs:
  trimmed_and_reformatted_reads:
    type: File
    outputSource:
      - trimming/trimmed_and_reformatted_reads
      - touch_empty_fasta/created_file
    pickValue: first_non_null
 
steps:

  count_overlapped_reads:
    run: ../../../utils/count_lines/count_lines.cwl
    in:
      sequences: reads
      number: { default: 4 }
    out: [ count ]

  # return empty_file == input_file if it is absolutely empty
  touch_empty_fasta:
    when: $(inputs.fastq_count == 0)
    run: ../../../utils/touch_file.cwl
    in:
      filename: { default: 'empty.fasta' }
      fastq_count: count_overlapped_reads/count
    out: [ created_file ]

  trimming:
    run: trimming-not-empty-subwf.cwl
    when: $(inputs.fastq_count != 0)
    in:
      not_empty_reads: reads
      fastq_count: count_overlapped_reads/count
    out: [ trimmed_and_reformatted_reads ]


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"

