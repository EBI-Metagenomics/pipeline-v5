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
  count: int

outputs:
  trimmed_and_reformatted_reads:
    type: File
    outputSource:
      - clean_fasta_headers/sequences_with_cleaned_headers
      - touch_empty_fasta/created_file
    pickValue: first_non_null
 
steps:

  # return empty_file == input_file if it is absolutely empty
  touch_empty_fasta:
    when: $(inputs.fastq_count == 0)
    run: ../../utils/touch_file.cwl
    in:
      filename: { default: 'empty.fasta' }
      fastq_count: count
    out: [ created_file ]

  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: reads
      chunk_size: { default: 1000000 }
      file_format: { default: 'fastq' }
      fastq_count: count
    out: [ chunks ]
    run: ../../tools/chunks/protein_chunker.cwl

  trim_quality_control:
    doc: |
      Low quality trimming (low quality ends and sequences with < quality scores
      less than 15 over a 4 nucleotide wide window are removed)
    run: ../../tools/Trimmomatic/Trimmomatic-v0.36-SE.cwl
    scatter: reads1
    when: $(inputs.fastq_count != 0)
    in:
      reads1: split_seqs/chunks
      phred: { default: '33' }
      leading: { default: 3 }
      trailing: { default: 3 }
      end_mode: { default: SE }
      minlen: { default: 100 }
      slidingwindow: { default: '4:15' }
      fastq_count: count
    out: [reads1_trimmed]

  combine_trimmed:
    when: $(inputs.fastq_count != 0)
    in:
      files: trim_quality_control/reads1_trimmed
      outputFileName:
        source: reads
        valueFrom: $(self.nameroot)
      postfix: { default: '.trimmed' }
      fastq_count: count
    out: [result]
    run: ../../utils/concatenate.cwl

  convert_trimmed_reads_to_fasta:
    when: $(inputs.fastq_count != 0)
    run: ../../utils/fastq_to_fasta/fastq_to_fasta.cwl
    in:
      fastq: combine_trimmed/result
      fastq_count: count
    out: [ fasta ]

  clean_fasta_headers:
    when: $(inputs.fastq_count != 0)
    run: ../../utils/clean_fasta_headers.cwl
    in:
      sequences: convert_trimmed_reads_to_fasta/fasta
      fastq_count: count
    out: [ sequences_with_cleaned_headers ]

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
