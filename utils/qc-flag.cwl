#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
label: output QC-FAILED or QC-PASSED file as intermediate flag

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 200  # just a default, could be lowered

inputs:
    qc_count:
        type: int

baseCommand: [ touch ]

arguments:
  - valueFrom: ${ var flag = "";
                 if (inputs.qc_count == 0) { flag = 'QC-FAILED'; }
                 else { flag = 'QC-PASSED'; }
                 return flag; }

outputs:
    qc-flag:
        type: File
        outputBinding:
            glob: QC-*

