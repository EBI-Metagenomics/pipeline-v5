cwlVersion: v1.0
class: ExpressionTool
requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
  ResourceRequirement:
    ramMin: 200
inputs:
  file_list: File[]?
  dir_list: Directory[]?
  dir_name: string

outputs:
  out: Directory
expression: |
  ${
    var listing = "";
    if (inputs.file_list) {
      listing = inputs.file_list;
    } else {
      listing = inputs.dir_list;
    }
    return {"out": {
      "class": "Directory",
      "basename": inputs.dir_name,
      "listing": listing
      }
    } };