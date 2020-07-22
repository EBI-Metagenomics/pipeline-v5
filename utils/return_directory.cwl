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
    var in_list = "";
    if (inputs.file_list) {
      in_list = inputs.file_list;
    } else {
      in_list = inputs.dir_list;
    }
    return {"out": {
      "class": "Directory",
      "basename": inputs.dir_name,
      "listing": in_list
      }
    }; }


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
