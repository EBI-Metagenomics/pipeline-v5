cwlVersion: v1.0
class: CommandLineTool
label: extract by names from an indexed sequence file
doc: "https://github.com/EddyRivasLab/easel"

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.easel:v0.45h

requirements:
  ResourceRequirement:
    ramMin: 200
    coresMin: 2

inputs:
  indexed_sequences:
    label: sequence file indexed by esl-sfetch-index
    type: File
    inputBinding:
      prefix: -Cf
      position: 1
    secondaryFiles:
       - .ssi
    format: edam:format_1929  # FASTA


  names_contain_subseq_coords:
    doc: |
        GDF format: <newname> <from> <to> <source seqname>
        space/tabdelimited
    type: File
    inputBinding:
      position: 2

baseCommand: [ esl-sfetch ]

stdout: $(inputs.indexed_sequences.basename)_$(inputs.names_contain_subseq_coords.basename).fasta

outputs:
  sequences:
    type: stdout
#    format: edam:format_1929  # FASTA

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

