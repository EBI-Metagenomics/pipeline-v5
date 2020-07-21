cwlVersion: v1.0
class: ExpressionTool

requirements:
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ResourceRequirement:
    ramMin: 200

inputs:

  number: int

outputs:
  out: int

expression: |
  ${
    var value = 0;
    if (inputs.number == 0 || inputs.number == 1) {
      value = 2;
    }
    else {
      value = inputs.number;
    }
    return {"out": value
    }; }