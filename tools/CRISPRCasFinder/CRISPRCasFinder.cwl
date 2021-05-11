cwlVersion: v1.2
class: CommandLineTool
label: CRIPRCasFinder
doc: |
      Implementation of CRISPRCasFinder.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.crisprcasfinder:4.2.21

baseCommand: [ "CRISPRCasFinder.pl" ]

arguments:
  - -cas
  - -cf 
  - CasFinder-2.0.3
  - -meta
  - -cpuM
  - $(runtime.cores)
  - -out
  - CRIPRCasFinder_out

inputs:
  sequences:
    type: File
    format: edam:format_1929
    label: input Fasta file to analyze
    inputBinding:
      position: 1
      prefix: -in
  soFile:
    type: string?
    label: path to the sel392v2.so file, required by vmatch
    default: /opt/CRISPRCasFinder/sel392v2.so
    inputBinding:
      position: 2
      prefix: -so
  casDefinition:
    type: string?
    label: Cas-finder definition, such as G (general), T (Typing) or S (Subtyping)
    default: G
    inputBinding:
      position: 3
      prefix: -def

outputs:
  crisprcasfinder_json:
    type: File
    outputBinding:
      glob: "CRIPRCasFinder_out/result.json"
  
stdout: crispcasfinder.log
stderr: crispcasfinder.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2021-01-27
