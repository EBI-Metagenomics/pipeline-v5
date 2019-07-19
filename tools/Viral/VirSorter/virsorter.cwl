#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool


label: "VirSorter"

requirements:
  DockerRequirement:
    dockerPull: simroux/virsorter:v1.0.5
  InlineJavascriptRequirement: {}

baseCommand: [wrapper_phage_contigs_sorter_iPlant.pl]

arguments: ["--db", "2"]

inputs:
  fasta_file:
    type: File
    inputBinding:
      separate: true
      prefix: "-f"
  data:
    type: Directory?
    default:
      class: Directory
      path:  virsorter-data
      listing: []
      basename: virsorter-data
    inputBinding:
      prefix: --data-dir
  dataset:
    type: string?
    inputBinding:
      separate: true
      prefix: "-d"
  custom_phage:
    type: string?
    inputBinding:
      separate: true
      prefix: "--cp"
  working_directory:
    type: string?
    inputBinding:
      separate: true
      prefix: "--wdir"
  number_of_cpu:
    type: int?
    inputBinding:
      separate: true
      prefix: "--ncpu"
  virome_decontamination_mode:
    type: null?
    inputBinding:
      separate: true
      prefix: "--virome"
  diamond:
    type: null?
    inputBinding:
      separate: true
      prefix: "--diamond"
  keep_db:
    type: null?
    inputBinding:
      separate: true
      prefix: "--keep-db"
  enrichment_statistics:
    type: null?
    inputBinding:
      separate: true
      prefix: "--no_c"


stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr
  predicted_viral_seq_dir:
     type: Directory
     outputBinding:
        glob: virsorter-out/Predicted_viral_sequences/

#  output_fasta:
#    type:
#      type: array
#      items: File
#    outputBinding:
#      glob: virsorter-out/Predicted_viral_sequences/*[1,2,3,4,5].fasta  #  virsorter: virsorter-out/Predicted_viral_sequences/*[1,2,3,4,5].fasta

doc: |
  usage: wrapper_phage_contigs_sorter_iPlant.pl --fasta sequences.fa

  Required Arguments:

      -f|--fna       Fasta file of contigs

   Options:

      -d|--dataset   Code dataset (DEFAULT "VIRSorter")
      --cp           Custom phage sequence
      --db           Either "1" (DEFAULT Refseqdb) or "2" (Viromedb)
      --wdir         Working directory (DEFAULT cwd)
      --ncpu         Number of CPUs (default: 4)
      --virome       Add this flag to enable virome decontamination mode, for datasets
                     mostly viral to force the use of generic metrics instead of
                     calculated from the whole dataset. (default: off)
      --data-dir     Path to "virsorter-data" directory (e.g. /path/to/virsorter-data)
      --diamond      Use diamond (in "--more-sensitive" mode) instead of blastp.
                     Diamond is much faster than blastp and may be useful for adding
                     many custom phages, or for processing extremely large Fasta files.
                     Unless you specify --diamond, VirSorter will use blastp.
      --keep-db      Specifying this flag keeps the new HMM and BLAST databases created
                     after adding custom phages. This is useful if you have custom phages
                     that you want to be included in several different analyses and want
                     to save the database and point VirSorter to it in subsequent runs.
                     By default, this is off, and you should only specify this flag if
                     you're SURE you need it.
      --no_c         Use this option if you have issues with empty output files, i.e. 0
                     viruses predicted by VirSorter. This make VirSorter use a perl function
                     instead of the C script to calculate enrichment statistics. Note that
                     VirSorter will be slower with this option.
      --help         Show help and exit
