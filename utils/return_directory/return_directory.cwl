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
  file_list:
    type:
    - "null"
    - type: array
      items: ["null", "File"]
  dir_list:
    type:
    - "null"
    - type: array
      items: ["null", "Directory"]
  dir_name: string

outputs:
  out: Directory

expression: |
  ${
    var list2 = [];
    var using_list = [];
    if (inputs.file_list != null) {
      using_list = inputs.file_list
    } else {
      using_list = inputs.dir_list }

    for (var item in using_list) {
      if (using_list[item] != null) {
          list2.push(using_list[item]) };
      }

    return {
      "out": {
        "class": "Directory",
        "basename": inputs.dir_name,
        "listing": list2
      }
    };
  }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"

