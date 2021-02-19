class: Workflow
cwlVersion: v1.2.0-dev2

requirements:
  - class: ResourceRequirement
    ramMin: 20000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
    include_protein_assign: boolean
    filtered_fasta: File
    config_db_file: File?
    study_accession: string?
    run_accession: string?
    public: int?
    CGC_postfixes: string[]
    cgc_chunk_size: int
    generate_map_file_flag: boolean

outputs:
  assigned_contigs:
    type: File
    outputSource: assign_mgyc/renamed_contigs_fasta
  predicted_proteins:
    type: File
    outputSource:
      - assign_mgyp/renamed_proteins
      - cgc/predicted_proteins
    pickValue: first_non_null
  predicted_seq:
    type: File
    outputSource: cgc/predicted_seq
  count_faa:
    type: int
    outputSource: cgc/count_faa
  mgyp_fasta_metadata:
    type: File?
    outputSource: assign_mgyp/proteins_metadata
  mgyp_fasta_stderr:
    type: File?
    outputSource: assign_mgyp/stderr_protein_assign
  mapfile_for_virify:
    type: File
    outputSource: generate_mapfile/mapfile

steps:

# -----------------------------------  << Assign MGYCs >>  -----------------------------------

  add_run_to_database:
    when: $(inputs.include_protein_assign_bool == true)
    run: ../../../tools/Assembly/accessioning/add_run_to_db/add_run_db.cwl
    in:
      include_protein_assign_bool: include_protein_assign
      study_accession: study_accession
      config_db_file: config_db_file
      run_accession: run_accession
      public: public
    out: [ logs ]

  assign_mgyc:
    run: ../../../tools/Assembly/accessioning/assign_MGYC/assign_mgyc.cwl
    when: $(inputs.include_protein_assign_bool == true)
    in:
      logs: add_run_to_database/logs
      include_protein_assign_bool: include_protein_assign
      input_fasta: filtered_fasta
      config_db_file: config_db_file
      run_accession: run_accession
    out: [ renamed_contigs_fasta ]

# -----------------------------------  << COMBINED GENE CALLER >>  -----------------------------------
  cgc:
    in:
      input_fasta:
        source:
          - assign_mgyc/renamed_contigs_fasta
          - filtered_fasta
        pickValue: first_non_null
      postfixes: CGC_postfixes
      chunk_size: cgc_chunk_size
    out: [ predicted_proteins, predicted_seq, count_faa]
    run: cgc/CGC-subwf.cwl

# -----------------------------------  << Assign MGYPs >>  -----------------------------------

  assign_mgyp:
    when: $(inputs.include_protein_assign_bool == true)
    run: ../../../tools/Assembly/accessioning/assign_MGYP/assign_mgyp.cwl
    in:
      include_protein_assign_bool: include_protein_assign
      input_fasta: cgc/predicted_proteins
      config_db_file: config_db_file
      run_accession: run_accession
    out: [ renamed_proteins, stderr_protein_assign, proteins_metadata ]

# -----------------------------------  << Generate map-file for viral pipeline >>  -------------------

  generate_mapfile:
    when: $(inputs.generate_map_file == true)
    in:
      generate_map_file: generate_map_file_flag
      input_fasta: assign_mgyp/renamed_proteins
      output_name:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
    out: [ mapfile ]
    run: ../../../tools/Assembly/generate_mapfile/generate_mapfile_prodigal.cwl


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
