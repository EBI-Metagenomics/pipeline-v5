#!/usr/bin/env python3

import argparse
import sys
import os

IPS_VERSION = "5.36-75.0"
DIAMOND_VERSION = "0.9.25"
UNIREF_VERSION = "v2019_11"

def ssu_lsu_dbs(file_yml, dir):
    file_yml.write("\n"
                   "ssu_db:\n  class: File\n  "
                   "path: {dir}/silva_ssu/SSU.fasta\n"
                   "  format: edam:format_1929\n  checksum: 6b0580823a8c6860a0674428745fb943\n"
                   "lsu_db:\n  class: File\n  "
                   "path: {dir}/silva_lsu/LSU.fasta\n"
                   "  format: edam:format_1929\n  checksum: 96dc05a4ab2933ec6f443a1a0ce0d225\n"
                   "ssu_tax:\n  class: File\n  "
                   "path: {dir}/silva_ssu/slv_ssu_filtered2.txt\n"
                   "  checksum: f4e7019da9e4c9e38cf3bbd8d304bf0c\n"
                   "lsu_tax:\n  class: File\n  "
                   "path: {dir}/silva_lsu/slv_lsu_filtered2.txt\n"
                   "  checksum: d521ce911cb9b94f4d304286ed9f8c3e\n"
                   "ssu_otus:\n  class: File\n  "
                   "path: {dir}/silva_ssu/ssu2.otu\n"
                   "  checksum: 75d6cb73018a4f969063de6927cfb1ab\n"
                   "lsu_otus:\n  class: File\n  "
                   "path: {dir}/silva_lsu/lsu2.otu\n"
                   "  checksum: 515df01f33ed8d5741fbe0e55e4780b9"
                   .format(dir=dir))


def rfam_models(file_yml, dir, type):
    file_yml.write("\n\nrfam_models:"
            "\n  - class: File\n    path: {dir}/ribosomal/RF00002.cm\n    checksum: 30af1b9283ed10bfb22fbd1571be51e9"
            "\n  - class: File\n    path: {dir}/ribosomal/RF00177.cm\n    checksum: 94a864300ab97ea91c8e334af1f15ccf"
            "\n  - class: File\n    path: {dir}/ribosomal/RF01959.cm\n    checksum: 358464d747ca08973983181e6c5d3c36"
            "\n  - class: File\n    path: {dir}/ribosomal/RF01960.cm\n    checksum: 7e207426e32053bdad4dbe325f4d53f2"
            "\n  - class: File\n    path: {dir}/ribosomal/RF02540.cm\n    checksum: 21c240b829b6c8d44acb320826dd3988"
            "\n  - class: File\n    path: {dir}/ribosomal/RF02541.cm\n    checksum: 909e8186ecff869c21bd4f17b17d6d18"
            "\n  - class: File\n    path: {dir}/ribosomal/RF02542.cm\n    checksum: f21a130574b87a3cae0eb4aab0f38e6a"
            "\n  - class: File\n    path: {dir}/ribosomal/RF02543.cm\n    checksum: 6ec013d40fbce6dbbb2a1c35e68d777c"
            "\n  - class: File\n    path: {dir}/ribosomal/RF02546.cm\n    checksum: 91f899f34613e77694b97c993414e5c2"
            "\n  - class: File\n    path: {dir}/ribosomal/RF02547.cm\n    checksum: 43f94845c34819ebbecfa9050a992ea9"
            .format(dir=dir))
    if type == 'assembly' or type == 'wgs':
        file_yml.write(
           "\n  - class: File\n    path: {dir}/other/alpha_tmRNA.cm\n    checksum: bb386488759438f4c3648044a6e7e990"
           "\n  - class: File\n    path: {dir}/other/Plant_SRP.cm\n    checksum: b0d6d8960d012a40f7b2b4c8ed50cb1f"
           "\n  - class: File\n    path: {dir}/other/Archaea_SRP.cm\n    checksum: 0b85ae3b178150ad302fe295ea5794dc"
           "\n  - class: File\n    path: {dir}/other/Protozoa_SRP.cm\n    checksum: 4f7bb93a56ea9e3f4f00df19e2b1efe3"
           "\n  - class: File\n    path: {dir}/other/Bacteria_large_SRP.cm\n    checksum: 0ce2c0407c18a6a6f67d907718556951"
           "\n  - class: File\n    path: {dir}/other/RNase_MRP.cm\n    checksum: 339d31cf05f52736c8036d8a28824f53"
           "\n  - class: File\n    path: {dir}/other/Bacteria_small_SRP.cm\n    checksum: aac546e28fe85eb6478dceab842b7ba2"
           "\n  - class: File\n    path: {dir}/other/RNaseP_arch.cm\n    checksum: 80b98e26b20e3dbcf025d5414023d5e1"
           "\n  - class: File\n    path: {dir}/other/beta_tmRNA.cm\n    checksum: af26a7a601e4b0ae4b7edf7c9459b02d"
           "\n  - class: File\n    path: {dir}/other/RNaseP_bact_a.cm\n    checksum: 4501e8e0357aefbf76849a619a423c94"
           "\n  - class: File\n    path: {dir}/other/cyano_tmRNA.cm\n    checksum: 60ba0326655a2b558ec7adad571c7d90"
           "\n  - class: File\n    path: {dir}/other/RNaseP_bact_b.cm\n    checksum: 3d5c292715b9df28d74ed032fdcb2041"
           "\n  - class: File\n    path: {dir}/other/Dictyostelium_SRP.cm\n    checksum: 57d27c4d9098f3a05447030c28330238"
           "\n  - class: File\n    path: {dir}/other/RNase_P.cm\n    checksum: 387d3694d17a2fd5bb9edebb586105af"
           "\n  - class: File\n    path: {dir}/other/Fungi_SRP.cm\n    checksum: b874eb43eca0af9dbdd402ae8cdc7d76"
           "\n  - class: File\n    path: {dir}/other/RNaseP_nuc.cm\n    checksum: d82176ee498688ffeaba25263956123e"
           "\n  - class: File\n    path: {dir}/other/Metazoa_SRP.cm\n    checksum: 2e0d37364dd446be81710d013d6b8947"
           "\n  - class: File\n    path: {dir}/other/tmRNA.cm\n    checksum: 2b6475b810ce90021bb742473bc1f455"
           "\n  - class: File\n    path: {dir}/other/mt-tmRNA.cm\n    checksum: 77b2478f1f638066d2eed2b18b0c518b"
           "\n  - class: File\n    path: {dir}/other/tRNA.cm\n    checksum: adf704922a7f539d0a2ea5132e36db42"
           "\n  - class: File\n    path: {dir}/other/tRNA-Sec.cm\n    checksum: 73b3442df0671d75ced6a540c4bc4b31"
           .format(dir=dir))


def unite_db(file_yml, dir):
    file_yml.write("\n\nunite_db:"
            "\n  class: File\n  path: {dir}/UNITE/unite.fasta\n  checksum: ddb2105cb1f1ffa8941b44c19022b5a3\n"
                   "  format: edam:format_1929\n"
                   "unite_tax:\n"
                   "  class: File\n  path: {dir}/UNITE/UNITE-tax.txt\n  checksum: 1fc36341db17533f7ae266a0dd07ae3b\n"
                   "unite_otu_file:\n"
                   "  class: File\n  path: {dir}/UNITE/UNITE.otu\n  checksum: da918f9884c7b96b8bd40f5a9afe4608"
                   .format(dir=dir))


def itsone_db(file_yml, dir):
    file_yml.write("\n\nitsonedb:"
            "\n  class: File\n  path: {dir}/ITSonedb/itsonedb.fasta\n  checksum: ec369f9fe6818482ce0ab184461ac116\n"
                   "  format: edam:format_1929\n"
                   "itsonedb_tax:\n"
                   "  class: File\n  path: {dir}/ITSonedb/ITSonedb-tax.txt\n  checksum: 2407aae69f77faf6690cae1571d2b33d\n"
                   "itsonedb_otu_file:\n"
                   "  class: File\n  path: {dir}/ITSonedb/ITSonedb.otu\n  checksum: e1f7350bfdfece0384f52072d45211f0"
                   .format(dir=dir))


def other_rna(file_yml):
    file_yml.write("\n\nother_ncRNA_models:\n  "
                   "- 'alpha_tmRNA.RF01849'\n  - 'Bacteria_large_SRP.RF01854'\n  "  
                   "- 'beta_tmRNA.RF01850'\n  - 'Dictyostelium_SRP.RF01570'\n  - 'Metazoa_SRP.RF00017'\n"
                   "  - 'Protozoa_SRP.RF01856'\n  - 'RNaseP_arch.RF00373'\n  - 'RNaseP_bact_b.RF00011'\n"
                   "  - 'RNaseP_nuc.RF00009'\n  - 'tRNA.RF00005'\n  - 'Archaea_SRP.RF01857'\n"
                   "  - 'Bacteria_small_SRP.RF00169'\n  - 'cyano_tmRNA.RF01851'\n  - 'Fungi_SRP.RF01502'\n"
                   "  - 'mt-tmRNA.RF02544'\n  - 'Plant_SRP.RF01855'\n  - 'RNase_MRP.RF00030'\n"
                   "  - 'RNaseP_bact_a.RF00010'\n  - 'RNase_P.RF01577'\n  - 'tmRNA.RF00023'\n  - 'tRNA-Sec.RF01852'\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parsing first sub-wf of pipeline")
    parser.add_argument("-d", "--dir", dest="dir", help="dir with all dbs", required=True)
    parser.add_argument("-t", "--type", dest="type", help="type of analysis: assembly/wgs/amplicon", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        with open(args.type + '.yml', 'w') as file_yml:
            # ==== for all types ====
            # EDAM
            file_yml.write("$namespaces:\n  s: https://schema.org" + "\n  edam: http://edamontology.org/\n")
            # rna prediction
            file_yml.write("\n#RNA prediction:\nssu_label: 'SSU_rRNA'\nlsu_label: 'LSU_rRNA'\n"
                           "5.8s_pattern: '5_8S_rRNA'\n5s_pattern: 'mtPerm-5S'\n")

            # ssu lsu
            ssu_lsu_dbs(file_yml, args.dir)
            # rfam_models
            rfam_models(file_yml, args.dir, args.type)

            if args.type == 'assembly' or args.type == 'wgs':
            # ==== for wgs and assembly ====
                # rfam_model_clans
                file_yml.write("\n"
                               "rfam_model_clans:\n  class: File\n  path: {dir}/rRNA.claninfo\n"
                               "  checksum: 4dffaadeaac92821c19bd0e5a152f370\n".format(dir=args.dir))
                # other RNA
                other_rna(file_yml)

                # CGC
                file_yml.write("\n"
                           "CGC_postfixes:\n  - '_CDS.faa'\n  - '_CDS.ffn'\n"
                               "cgc_chunk_size: 100000")
                # functional annotation
                file_yml.write("\n"
                           "fa_chunk_size: 100000\n"
                           "func_ann_names_ips: .I5.tsv.without_header\n"
                           "func_ann_names_hmmscan: .hmm.tsv.without_header\n")
                # hmmer
                file_yml.write("\n"
                           "HMMSCAN_gathering_bit_score: true\n"
                           "HMMSCAN_omit_alignment: true\n"
                           "HMMSCAN_name_database: db_kofam.hmm\n"
                           "HMMSCAN_data:\n  class: Directory\n"
                           "  path: {dir}/db_kofam/\n".format(dir=args.dir))
                file_yml.write("\nhmmscan_header: 'target_name\ttarget_accession\ttlen\tquery_name\tquery_accession\tqlen"
                               "\tfull_sequence_e-value\tfull_sequence_score\tfull_sequence_bias\t#\tof\tc-evalue"
                               "\ti-evalue\tdomain_score\tdomain_bias\thmm_coord_from\thmm_coord_to\tali_coord_from"
                               "\tali_coord_to\tenv_coord_from\tenv_coord_to\tacc\tdescription_of_target'")
                # IPS
                file_yml.write("\n"
                               "InterProScan_applications:\n  - PfamA\n  - TIGRFAM\n  - PRINTS\n  - PrositePatterns\n"
                               "  - Gene3d\n"
                               "InterProScan_outputFormat:\n  - TSV\n"
                               "InterProScan_databases:\n  class: Directory\n  path: {dir}/interproscan-{ips}/data\n"
                               "ips_header: 'protein_accession\tsequence_md5_digest\tsequence_length\tanalysis"
                               "\tsignature_accession\tsignature_description\tstart_location\tstop_location\tscore"
                               "\tstatus\tdate\taccession\tdescription\tgo\tpathways_annotations'"
                               .format(dir=args.dir, ips=IPS_VERSION))

                if args.type == 'assembly':
                # ===== only assembly =====
                    print('assembly')
                    file_yml.write("\ncontig_min_length: 500\n")

                    # eggnog
                    file_yml.write("\nEggNOG_db:\n  path: {dir}/eggnog/eggnog.db\n  class: File\n"
                                   "EggNOG_diamond_db:\n"
                                   "  path: {dir}/eggnog/eggnog_proteins.dmnd\n  class: File\n"
                                   "EggNOG_data_dir: \n"
                                    "  class: Directory\n"
                                   "  path: {dir}/eggnog/".format(dir=args.dir))
                    # diamond
                    file_yml.write("\n\nUniref90_db_txt:\n  path: {dir}/diamond/db_uniref90_{uniref}.txt\n  class: File\n"
                           "diamond_maxTargetSeqs: 1\n"
                           "diamond_databaseFile: \n"
                           "  class: File\n"
                           "  path: {dir}/diamond/uniref90_{uniref}_diamond-v{diamond}.dmnd\n"
                        "diamond_header: 'uniref90_ID\tcontig_name\tpercentage_of_identical_matches\tlenght\tmismatch"
                                   "\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tprotein_name"
                                   "\tnum_in_cluster\ttaxonomy\ttax_id\trep_id'"
                                   .format(dir=args.dir, uniref=UNIREF_VERSION, diamond=DIAMOND_VERSION))

                    # pathways
                    file_yml.write("\n\ngraphs:\n  class: File\n  "
                                   "path: {dir}/kegg_pathways/graphs.pkl\n"
                                   "pathways_names:\n  class: File\n  path: {dir}/kegg_pathways/all_pathways_names.txt\n"
                                   "pathways_classes:\n"
                                   "  class: File\n  path: {dir}/kegg_pathways/all_pathways_class.txt"
                                   .format(dir=args.dir))
                    # antismash
                    file_yml.write("\n\nclusters_glossary:\n  class: File\n  path: {dir}/antismash_glossary.tsv\n"
                                   "  checksum: bd50e85246dc3609f7cab6fb4efe4845".format(dir=args.dir))
                else:
                # ==== only wgs ====
                    print('wgs')
                    file_yml.write("\nqc_min_length: 100\n")
            else:
            # ====== only amplicon =======
                print('amplicon')
                file_yml.write("\n"
                               "qc_min_length: 100\n"
                               "stats_file_name: 'qc_summary'\n"
                               "unite_label: 'UNITE'\n"
                               "itsonedb_label: 'ITSonedb'\n")
                # rfam_model_clans
                file_yml.write("\n"
                                "rfam_model_clans:\n  class: File\n  path: {dir}/ribosomal/ribo.claninfo\n"
                               "  checksum: ed55b0130da268e5deca604fa34da618\n".format(dir=args.dir))
                # UTINE
                unite_db(file_yml, args.dir)
                # ITSoneDB
                itsone_db(file_yml, args.dir)
        file_yml.close()
        print('---------> yml done')