class: Workflow
cwlVersion: v1.2.0-dev2

label: "WF leaves sequences that length is more than 1000bp, run antismash + gene clusters post-processing, GFF generation"

requirements:
  - class: ResourceRequirement
    ramMin: 5000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
    jsons: File[]
    filtered_fasta: File

outputs:
  antismash_result_json:
    type: File
    outputSource: add_the_first_bracket_json/output_json

steps:

  filter_empty_jsons:
    run: ../filter_empty_jsons/filter_jsons.cwl
    in:
      input_jsons: jsons
    out: [ non_empty_jsons ]

  remove_curly_brackets_chunks_json:
    run: remove_symbol.cwl
    scatter: input_json
    in:
      type: { default: "both" }
      input_json: filter_empty_jsons/non_empty_jsons
      outputname:
        source: filtered_fasta
        valueFrom: $(self.nameroot).remove.json
    out: [ output_json ]

  add_the_last_comma_json:
    run: add_symbol.cwl
    scatter: input_json
    in:
      input_json: remove_curly_brackets_chunks_json/output_json
      outputname: { default: geneclusters.comma.json }
      symbol: { default: "," }
      type: { default: "last" }
    out: [ output_json ]

  unite_geneclusters_jsons:
    run: ../../../../../../utils/concatenate.cwl
    in:
      files: add_the_last_comma_json/output_json
      outputFileName: { default: geneclusters.fix.json }
    out:  [ result ]

  remove_the_last_comma:
    run: remove_symbol.cwl
    in:
      type: { default: "last"}
      input_json: unite_geneclusters_jsons/result
      outputname:
        source: filtered_fasta
        valueFrom: $(self.nameroot).remove_comma.json
    out: [ output_json ]

  add_the_last_bracket_json:
    run: add_symbol.cwl
    in:
      input_json: remove_the_last_comma/output_json
      outputname: { default: geneclusters.last.json }
      symbol: { default: "}" }
      type: { default: "last" }
    out: [ output_json ]

  add_the_first_bracket_json:
    run: add_symbol.cwl
    in:
      input_json: add_the_last_bracket_json/output_json
      outputname: { default: geneclusters.json }
      symbol: { default: "{" }
      type: { default: "first" }
    out: [ output_json ]
