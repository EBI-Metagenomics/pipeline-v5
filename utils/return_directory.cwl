cwlVersion: v1.0
class: ExpressionTool
requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
inputs:
  list: File[]
outputs:
  out: Directory
expression: |
  ${
    return {"out": {
      "class": "Directory",
      "basename": "my_directory_name",
      "listing": inputs.list
    } };
  }