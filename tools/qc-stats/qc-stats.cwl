cwlVersion: v1.0
class: CommandLineTool

#MGRAST_base.py -l seq-length.out.full -g GC-distribution.out.full -d nucleotide-distribution.out.full -o summary -m 2000000 -i merged_with_unmerged_reads.trimmed.fastq.fasta
label: "Post QC-ed input analysis of sequence file"

#doc: |

requirements:
#  DockerRequirement:
#    dockerPull: qc-stats:latest
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered
  InlineJavascriptRequirement: {}

inputs:
  QCed_reads:
    type: File
    format: edam:format_1929  # FASTA
    inputBinding:
      prefix: -i
  length_sum:
    label: Prefix for the files assocaited with sequence length distribution
    type: string
    default: seq-length.out
    inputBinding:
      prefix: -l
  gc_sum:
    label: Prefix for the files associated with GC distribution
    type: string
    default: GC-distribution.out
    inputBinding:
      prefix: -g
  nucleotide_distribution:
    label: Prefix for the files associated with nucleotide distribution
    type: string
    default: nucleotide-distribution.out
    inputBinding:
      prefix: -d
  summary:
    label: File names for summary of sequences, e.g. number, min/max length etc.
    type: string
    default: summary.out
    inputBinding:
      prefix: -o
  max_seq:
    label: Maximum number of sequences to sub-sample 
    type: int?
    default: 2000000
    inputBinding:
      prefix: "-m"

baseCommand: ["MGRAST_base.py" ]

outputs:
  summary_out:
    label: Contains the summary statistics for the input sequence file
    type: File
    format: iana:text/plain
    outputBinding:
      glob: $(inputs.summary)

  seq_length_pcbin:
    label: Contains the binned length distribution expressed as percentage
    type: File
    format: iana:text/tab-separated-values
    outputBinding:
      glob: $(inputs.length_sum)_pcbin

  seq_length_bin:
    label: Contains the binned length distribution, real numbers
    type: File
    format: iana:text/tab-separated-values
    outputBinding:
      glob: $(inputs.length_sum)_bin

  seq_length_out:
    label: Contains all the lengths observed and frequencies
    type: File
    format: iana:text/tab-separated-values
    outputBinding:
      glob: $(inputs.length_sum)

  nucleotide_distribution_out:
    label: Contains the normalised fraction of nucleotides on the sequences
    type: File
    format: iana:text/tab-separated-values
    outputBinding:
      glob: $(inputs.nucleotide_distribution)

  gc_sum_pcbin:
    label: Contains the binned GC distribution, percentage
    type: File
    format: iana:text/tab-separated-values
    outputBinding:
      glob: $(inputs.gc_sum)_pcbin

  gc_sum_bin:
    label: Contains the binned GC distribution, real numbers
    type: File
    format: iana:text/tab-separated-values
    outputBinding:
      glob: $(inputs.gc_sum)_bin

  gc_sum_out:
    label: Contains all GC fractsions observed and sequence counts
    type: File
    format: iana:text/tab-separated-values
    outputBinding:
      glob: $(inputs.gc_sum)

$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:   "EMBL - European Bioinformatics Institute"
