cwlVersion: v1.0
class: ExpressionTool
requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
  ResourceRequirement:
    ramMin: 100
inputs:
  list: File[]
  dir_name: string
outputs:
  out: Directory
expression: |
  ${
    return {"out": {
      "class": "Directory",
      "basename": inputs.dir_name,
      "listing": inputs.list
    } };
  }