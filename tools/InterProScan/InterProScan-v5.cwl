class: CommandLineTool
cwlVersion: v1.0

label: 'InterProScan: protein sequence classifier'

id: i5
baseCommand: []

arguments:
  - position: 0
    shellQuote: false
    valueFrom: cp -r /opt/interproscan $(runtime.outdir)/interproscan;
# TODO: Works for cwl-runner & cwlexec
#  This solution will cause symbolic link creating warnings for the freemarker files
  - position: 1
    shellQuote: false
    valueFrom: >-
      cp -rs $(inputs.databases.path)/data/*
      $(runtime.outdir)/interproscan/data;
# TODO: The following solution will work for cwl-runner but not for cwlexec
#  This solution avoids the symbolic link creating warnings for the freemarker files
#  - position: 1
#    shellQuote: false
#    valueFrom: >-
#      find $(inputs.databases.path)/data/ -maxdepth 1 -mindepth 1
#      -type d -not -iname '*freemarker' -exec cp -rs '{}' '$(runtime.outdir)/interproscan/data' \\;;
  - position: 2
    shellQuote: false
    valueFrom: $(runtime.outdir)/interproscan/interproscan.sh
  - position: 3
    valueFrom: '--disable-precalc'
  - position: 4
    valueFrom: '--goterms'
  - position: 5
    valueFrom: '--pathways'
  - position: 6
    prefix: '--tempdir'
    valueFrom: $(runtime.tmpdir)

inputs:
  - id: inputFile
    # format: 'edam:format_1929'
    type: File
    inputBinding:
      position: 8
      prefix: '--input'
    label: Input file path
    doc: >-
      Optional, path to fasta file that should be loaded on Master startup.
      Alternatively, in CONVERT mode, the InterProScan 5 XML file to convert.
  - id: applications
    type: string  # InterProScan-apps.yaml#apps[]?
    inputBinding:
      position: 9
      itemSeparator: ','
      prefix: '--applications'
    label: Analysis
    doc: >-
      Optional, comma separated list of analyses. If this option is not set, ALL
      analyses will be run.
  - id: outputFormat
    type: string  # InterProScan-protein_formats.yaml#protein_formats[]?
    default: TSV
    inputBinding:
      position: 10
      itemSeparator: ','
      prefix: '--formats'
    label: output format
    doc: >-
      Optional, case-insensitive, comma separated list of output formats.
      Supported formats are TSV, XML, JSON, GFF3, HTML and SVG. Default for
      protein sequences are TSV, XML and GFF3, or for nucleotide sequences GFF3
      and XML.
  - id: databases
    type: Directory
  - id: disableResidueAnnotation
    type: boolean?
    inputBinding:
      position: 11
      prefix: '--disable-residue-annot'
    label: Disables residue annotation
    doc: 'Optional, excludes sites from the XML, JSON output.'
  - id: seqtype
    type:
      - 'null'
      - type: enum
        symbols:
          - p
          - n
        name: seqtype
    inputBinding:
      position: 12
      prefix: '--seqtype'
    label: Sequence type
    doc: >-
      Optional, the type of the input sequences (dna/rna (n) or protein (p)).
      The default sequence type is protein.

outputs:
  - id: i5Annotations
    type: File
    outputBinding:
      glob: $(inputs.inputFile.basename).tsv

requirements:
  - class: ShellCommandRequirement
#  - class: SchemaDefRequirement
#    types:
#      - $import: InterProScan-apps.yaml
#      - $import: InterProScan-protein_formats.yaml
  - class: ResourceRequirement
    ramMin: 2048
    ramMax: 8192
    coresMin: 4
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: 'biocontainers/interproscan:v5.30-69.0_cv1'

$namespaces:
  edam: 'http://edamontology.org/'
  iana: 'https://www.iana.org/assignments/media-types/'
  s: 'http://schema.org/'

$schemas:
  - 'http://edamontology.org/EDAM_1.20.owl'
  - 'https://schema.org/version/latest/schema.rdf'
's:author': 'Michael Crusoe, Aleksandra Ola Tarkowska, Maxim Scheremetjew'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': 'https://www.apache.org/licenses/LICENSE-2.0'


doc: >-
  InterProScan is the software package that allows sequences (protein and
  nucleic) to be scanned against InterPro's signatures. Signatures are
  predictive models, provided by several different databases, that make up the
  InterPro consortium.


  This tool description is using a Docker container tagged as version
  v5.30-69.0.


  Documentation on how to run InterProScan 5 can be found here:
  https://github.com/ebi-pf-team/interproscan/wiki/HowToRun