cwlVersion: v1.0
class: CommandLineTool

#MGRAST_base.py -l seq-length.out.full -g GC-distribution.out.full -d nucleotide-distribution.out.full -o summary -m 2000000 -i merged_with_unmerged_reads.trimmed.fastq.fasta
label: "Post QC-ed input analysis of sequence file"

#doc: |

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.python2:v1

requirements:
  ResourceRequirement:
    coresMin: 4
    ramMin: 900
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
       - entry: "$({class: 'Directory', listing: []})"
         entryname: $(inputs.out_dir_name)
         writable: true

baseCommand: ["MGRAST_base.py" ]

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
  gc_sum:
    label: Prefix for the files associated with GC distribution
    type: string
    default: GC-distribution.out
  nucleotide_distribution:
    label: Prefix for the files associated with nucleotide distribution
    type: string
    default: nucleotide-distribution.out
  summary:
    label: File names for summary of sequences, e.g. number, min/max length etc.
    type: string
    default: summary.out
  max_seq:
    label: Maximum number of sequences to sub-sample 
    type: int?
    default: 2000000
  out_dir_name:
    label: Specifies output subdirectory
    type: string
    default: qc-statistics
  sequence_count:
    label: Specifies the number of sequences in the input read file (FASTA formatted)
    type: int


outputs:
  output_dir:
    label: Contains all stats output files
    type: Directory
    outputBinding:
      glob: $(inputs.out_dir_name)
  summary_out:
    label: Contains the summary statistics for the input sequence file
    type: File
    format: iana:text/plain
    outputBinding:
      glob: $(inputs.out_dir_name)/$(inputs.summary)

arguments:
   - position: 1
     prefix: '-o'
     valueFrom: $(inputs.out_dir_name)/$(inputs.summary)
   - position: 2
     prefix: '-d'
     valueFrom: |
       ${ var suffix = '.full';
          if (inputs.sequence_count > inputs.max_seq) {
            suffix = '.sub-set';
          }
          return "".concat(inputs.out_dir_name, '/', inputs.nucleotide_distribution, suffix);
       }
   - position: 3
     prefix: '-g'
     valueFrom: |
       ${ var suffix = '.full';
          if (inputs.sequence_count > inputs.max_seq) {
            suffix = '.sub-set';
          }
          return "".concat(inputs.out_dir_name, '/', inputs.gc_sum, suffix);
       }
   - position: 4
     prefix: '-l'
     valueFrom: |
       ${ var suffix = '.full';
          if (inputs.sequence_count > inputs.max_seq) {
            suffix = '.sub-set';
          }
          return "".concat(inputs.out_dir_name, '/', inputs.length_sum, suffix);
       }
   - position: 5
     valueFrom: ${ if (inputs.sequence_count > inputs.max_seq) { return '-m '.concat(inputs.max_seq)} else { return ''} }


$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:   "EMBL - European Bioinformatics Institute"
