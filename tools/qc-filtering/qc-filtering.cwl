cwlVersion: v1.0
class: CommandLineTool

label: "Quality control filtering step using the BioPython package."

requirements:
#  DockerRequirement:
#    dockerPull: alpine:3.7
  ResourceRequirement:
    coresMax: 4
    ramMin: 100
    ramMax: 500
  InlineJavascriptRequirement: {}

baseCommand: ["run_quality_filtering.py" ]

inputs:
  seq_file:
    type: File
    format: edam:format_1929  # FASTA

outputs:
  filtered_file:
    label: Filtered output file
    type: File
    outputBinding:
      glob: $(inputs.seq_file.nameroot)_post-qc.fasta
  stats:
    type: stdout

arguments:
   - position: 1
     valueFrom: $(inputs.seq_file)
   - position: 2
     valueFrom: $(inputs.seq_file.nameroot)_post-qc.fasta

$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:   "EMBL - European Bioinformatics Institute"
