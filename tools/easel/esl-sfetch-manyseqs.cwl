cwlVersion: v1.0
class: CommandLineTool
label: extract by names from an indexed sequence file
doc: "https://github.com/EddyRivasLab/easel"

#hints:
# DockerRequirement:
#   dockerPull: quay.io/biocontainers/hmmer:3.2.1--hf484d3e_1


inputs:
  indexed_sequences:
    label: sequence file indexed by esl-sfetch-index
    type: File
    inputBinding:
      prefix: -Cf
      position: 1
#    secondaryFiles:
#       - .ssi
#    format: edam:format_1929  # FASTA


  names_contain_subseq_coords:
    doc: |
        GDF format: <newname> <from> <to> <source seqname>
        space/tabdelimited
    type: File
    inputBinding:
      position: 2

baseCommand: [ esl-sfetch ]

stdout: $(inputs.indexed_sequences.nameroot)_$(inputs.names_contain_subseq_coords.nameroot).fasta

outputs:
  sequences:
    type: stdout
#    format: edam:format_1929  # FASTA

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
