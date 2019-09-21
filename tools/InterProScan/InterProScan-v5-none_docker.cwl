class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  edam: 'http://edamontology.org/'
  iana: 'https://www.iana.org/assignments/media-types/'
  s: 'http://schema.org/'
id: i5
baseCommand: interproscan.sh
inputs:
  - id: inputFile
    type: File
    inputBinding:
      position: 8
      prefix: '--input'
    label: Input file path
    doc: >-
      Optional, path to fasta file that should be loaded on Master startup.
      Alternatively, in CONVERT mode, the InterProScan 5 XML file to convert.
  - id: applications
    type: string[]?
    inputBinding:
      position: 9
      itemSeparator: ','
      prefix: '--applications'
    label: Analysis
    doc: >-
      Optional, comma separated list of analyses. If this option is not set, ALL
      analyses will be run.
  - id: outputFormat
    type: string[]
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
    type: Directory?
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
      glob: $(inputs.inputFile.nameroot).f*.tsv
doc: >-
  InterProScan is the software package that allows sequences (protein and
  nucleic) to be scanned against InterPro's signatures. Signatures are
  predictive models, provided by several different databases, that make up the
  InterPro consortium.
  This tool description is using a Docker container tagged as version
  v5.30-69.0.
  Documentation on how to run InterProScan 5 can be found here:
  https://github.com/ebi-pf-team/interproscan/wiki/HowToRun
label: 'InterProScan: protein sequence classifier'
arguments:
  - position: 0
    valueFrom: '--disable-precalc'
  - position: 1
    valueFrom: '--goterms'
  - position: 2
    valueFrom: '--pathways'
  - position: 3
    prefix: '--tempdir'
    valueFrom: $(runtime.tmpdir)
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 10000
    coresMin: 4
  - class: InlineJavascriptRequirement
#  - class: SchemaDefRequirement
#    types:
#      - type: enum
#        name: outputFormats
#        symbols: [ TSV, XML, JSON, GFF3 ]
$schemas:
  - 'http://edamontology.org/EDAM_1.20.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'
's:author': 'Michael Crusoe, Aleksandra Ola Tarkowska, Maxim Scheremetjew'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': 'https://www.apache.org/licenses/LICENSE-2.0'
