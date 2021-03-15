# Tests for pipeline-v5

## Conformance tests
```bash
bash conformance-tests/conformance-tests.sh
```

## cwltest
```bash
bash cwltest/cwltest.sh -c True -t True -s True -u True -w True -p True  # with container

bash cwltest/cwltest.sh -c False -t True -s True -u True -w True -p True  # without container
```

#### Structure of tests

**Sub-workflows and Tools**
- seqprep
  - SE [subwf#3]
  - PE [subwf#4] 
    - SeqPrep tool [tool#5]
- trimming
  - trimming [subwf#5]
  - empty input [subwf#6]
    - Trimmomatic PE [tool#1]
    - Trimmomatic SE [tool#2]
- QC
  - qc-stats [tool#20]
  - qc-filtering [tool#21]
- other ncRNAs [subwf#7]
  - pull ncRNA [tool#8]
- RNA prediction
  - LSU+SSU [subwf#26]
  - only LSU [subwf#27]
  - only SSU [subwf#28]
    - easel index [tool#15]
    - cmsearch 
      - assembly [subwf#19]
      - raw-reads [subwf#20]
        - cmsearch [tool#17] [docker#64]
        - cmsearch-deoverlap [tool#18]
    - extract-coords [tool#14]
    - get_subunits_coords [tool#13]
    - easel many seqs [tool#16]
    - get_subunits_fasta [tool#12]
    - classify-otu-visualise [subwf#25]
      - mapseq [tool#6]
      - mapseq2biom [tool#7]
      - krona [tool#9]
      - biom-convert hdf5 [tool#10]
      - biom-convert json [tool#11]
- CGC
  - assembly [subwf#24]
    - predict_proteins_assemblies [subwf#22]
      - prodigal [tool#32] [docker#68]
      - FragGeneScan [tool#33]
      - post-processing prodigal + FGS [tool#35]
  - raw-reads [subwf#23]
    - predict_proteins_reads [subwf#21]
      - post-processing only FGS [tool#34]
- functional-annotation 
  - assembly [subwf#29]
  - raw-reads [subwf#30]
    - hmmer
      - hmmscan sub-wf [subwf#1]
        - hmmscan [tool#29] [docker#67]
      - hmmsearch sub-wf [subwf#2]
        - hmmscan + hmmer-tab-modification [tool#31]
          - hmmsearch [tool#28] [docker#66]
          - hmmer-tab-modification [tool#30]
    - IPS-chunking [subwf#8]
      - InterProScan [tool#26]
    - eggnog [subwf#11]
      - Eggnog seed_orthologs [tool#46] [docker#72]
      - Eggnog annotations [tool#47]
- post-proccessing-go-pfam-stats-subwf
  - GoSlim Summary [tool#27]
  - Pfam parse [tool#22]
  - func_summaries
    - assembly [subwf#17]
      - summaries [tool#4]
      - write_summaries [tool#36]
    - raw-reads [subwf#18]
      - summaries [tool#3]
      - write_summaries [tool#37]
  - chunking
    - fasta-file 1 chunk [tool#38]
    - fasta-file 3 chunks [tool#39]
    - fasta-file empty input [tool#40]
- assembly processing
  - generate mapfile for viral pipeline [tool#62]
  - index_fasta [tool#41] [docker#69]
  - antismash 
    - main sub-wf empty input [subwf#14]
    - main sub-wf [subwf#15]
      - antismash annotation subsubwf [subwf#16]
        - check_value 
          - 3 [tool#52]
          - 0 [tool#53]
        - filtering fasta before antismash [tool#61]
        - rename_contigs [tool#54]
        - antismash 
            - v4.2.0 good input [tool#59] [docker#73]
            - v4.2.0 bad input [tool#60]
        - post-processing
          - fix_embl_gbk [tool#55]
          - fix_geneclusters_txt [tool#56]
          - reformat geneclusters.txt [tool#57]
          - gff [tool#58] [docker#70]
        - move_antismash_summary [tool#51]
  - diamond
    - diamond-subwf [subwf#13]
      - Diamond blastP [tool#48]
      - diamond-post-processing [subwf#12]
        - Diamond post-processing sort input table [tool#49]
        - Diamond post-processing join tables [tool#50]
  - KEGG pathways [subwf#9]
    - KEGG modification [tool#42]
    - KEGG parsing hmm table [tool#43]
    - KEGG get kegg pathways [tool#44]
  - change_formats_and_names [subwf#10]
  - Genome Properties [tool#45] [docker#71]
  - GFF [tool#63]
- raw-reads processing
  - mOTUs [subwf#31]
    - motus [tool#19] [docker#65]
- ITS processing
  - bedtools [tool#23]
  - format-bedfile [tool#24]
  - suppress taxonomy [tool#25]

**Workflows**
- amplicon 
- assembly
- raw-reads
