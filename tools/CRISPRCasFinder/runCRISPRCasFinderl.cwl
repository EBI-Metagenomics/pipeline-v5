cwlVersion: v1.2
class: Workflow
label: runCRISPRCasFinder
doc: |
      Implementation of CRISPRCasFinder processing.

requirements:
  SubworkflowFeatureRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000

inputs:
  sequences:
    type: File
    format: edam:format_1929
    label: input Fasta file to analyze
  soFile:
    type: string?
    label: path to the sel392v2.so file, required by vmatch
    default: /opt/CRISPRCasFinder/sel392v2.so
  casDefinition:
    type: string?
    label: Cas-finder definition, such as G (general), T (Typing) or S (Subtyping)
    default: G
  spacer_fasta:
    type: string?
    label: Fasta with spacer sequences
    default: "CRISPRCasFinder_Spacers.fasta"
  crisprcas_gff:
    type: string?
    label: GFF3 with CRISPRCas results
    default: "CRISPRCasFinder.gff3"

outputs:
  #crisprcasfinder_json:
  #  type: File
  #  outputSource: run_crispcasfinder/crisprcasfinder_json
  crisprcasfinder_fasta:
    type: File
    format: edam:format_1929
    outputSource: convert2fasta/crisprcasfinder_fasta
  crisprcasfinder_gff:
    type: File
    format: edam:format_1975
    outputSource: convert2gff/crisprcasfinder_gff

steps:
    run_crispcasfinder:
      label: run CRIPRCasFinder tool
      run: CRISPRCasFinder.cwl
      in:
        sequences: sequences
        soFile: soFile
        casDefinition: casDefinition
      out:
        - crisprcasfinder_json

    convert2fasta:
      label: extract spacer sequences as fasta
      run: CRISPRCasFinder2Fasta.cwl
      in:
        in_json: run_crispcasfinder/crisprcasfinder_json
        out_fasta: spacer_fasta
      out:
        - crisprcasfinder_fasta

    convert2gff:
      label: convert output to GFF3
      run: CRISPRCasFinder2GFF.cwl
      in:
        in_json: run_crispcasfinder/crisprcasfinder_json
        out_gff: crisprcas_gff
      out:
        - crisprcasfinder_gff


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2021-04-15
