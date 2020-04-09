cwlVersion: v1.0
class: Workflow
label: Trim and reformat reads (single and paired end version)

requirements:
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  reads:
    type: File

outputs:
  trimmed_and_reformatted_reads:
    type: File
    outputSource: clean_fasta_headers/sequences_with_cleaned_headers
 
steps:

  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: reads
      chunk_size: { default: '2000000' }
    out: [ chunks ]
    run: ../../tools/chunks/fasta_chunker.cwl

  trim_quality_control:
    doc: |
      Low quality trimming (low quality ends and sequences with < quality scores
      less than 15 over a 4 nucleotide wide window are removed)
    run: ../../tools/Trimmomatic/Trimmomatic-v0.36-SE.cwl
    in:
      reads1: chunks
      phred: { default: '33' }
      leading: { default: 3 }
      trailing: { default: 3 }
      end_mode: { default: SE }
      minlen: { default: 100 }
      slidingwindow: { default: '4:15' }
    scatter: reads1
    out: [reads1_trimmed]

  combine_trimmed:
    in:
      files: trim_quality_control
      outputFileName:
        source: reads
        valueFrom: $(self.nameroot.split).trimmed
      postfix: name_ips
    out: [result]
    run: ../../utils/concatenate.cwl

  convert_trimmed_reads_to_fasta:
    run: ../../utils/fastq_to_fasta/fastq_to_fasta.cwl
    in:
      fastq: combine_trimmed/result
    out: [ fasta ]

  clean_fasta_headers:
    run: ../../utils/clean_fasta_headers.cwl
    in:
      sequences: convert_trimmed_reads_to_fasta/fasta
    out: [ sequences_with_cleaned_headers ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
