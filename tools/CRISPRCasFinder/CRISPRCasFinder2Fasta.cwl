cwlVersion: v1.2
class: CommandLineTool
label: CRIPRCasFinder2Fasta
doc: |
      convert CRISPRCasFinder output to Fasta.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.crisprcasfinder:4.2.21

baseCommand: [ "crisprcf2fasta.py" ]

inputs:
  in_json:
    type: File
    label: input JSON file
    inputBinding:
      position: 1
      prefix: -j
  out_fasta:
    type: string?
    label: output file with spacer sequences (fasta)
    default: "CrisprCasFinder_Spacers.fasta"
    inputBinding:
      position: 2
      prefix: -o

outputs:
  crisprcasfinder_fasta:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: $(inputs.out_fasta)
  
stdout: crisprcf2fasta.log
stderr: crisprcf2fasta.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2021-04-14
