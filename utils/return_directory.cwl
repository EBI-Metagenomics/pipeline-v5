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
    var in_list = "";
    var list2 = [];
    if (inputs.file_list != null) {
      for (const item in inputs.file_list) {
        if (inputs.file_list[item] != null) {
            list2.push(inputs.file_list[item]) };
        }
      in_list = list2;
    } else {
      in_list = inputs.dir_list;
    }
    return {
      "out": {
        "class": "Directory",
        "basename": inputs.dir_name,
        "listing": in_list
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
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
