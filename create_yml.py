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
                   "ssu_tax: {dir}/silva_ssu/slv_ssu_filtered2.txt\n"
                   "lsu_tax: {dir}/silva_lsu/slv_lsu_filtered2.txt\n"
                   "ssu_otus: {dir}/silva_ssu/ssu2.otu\n"
                   "lsu_otus: {dir}/silva_lsu/lsu2.otu\n"
                   .format(dir=dir))


def rfam_models(file_yml, dir, type):
    file_yml.write("\n\nrfam_models:"
            "\n  - {dir}/ribosomal/RF00002.cm"
            "\n  - {dir}/ribosomal/RF00177.cm"
            "\n  - {dir}/ribosomal/RF01959.cm"
            "\n  - {dir}/ribosomal/RF01960.cm"
            "\n  - {dir}/ribosomal/RF02540.cm"
            "\n  - {dir}/ribosomal/RF02541.cm"
            "\n  - {dir}/ribosomal/RF02542.cm"
            "\n  - {dir}/ribosomal/RF02543.cm"
            "\n  - {dir}/ribosomal/RF02546.cm"
            "\n  - {dir}/ribosomal/RF02547.cm"
            .format(dir=dir))
    if type == 'assembly' or type == 'wgs':
        file_yml.write(
           "\n  - {dir}/other/alpha_tmRNA.cm"
           "\n  - {dir}/other/Plant_SRP.cm"
           "\n  - {dir}/other/Archaea_SRP.cm"
           "\n  - {dir}/other/Protozoa_SRP.cm"
           "\n  - {dir}/other/Bacteria_large_SRP.cm"
           "\n  - {dir}/other/RNase_MRP.cm"
           "\n  - {dir}/other/Bacteria_small_SRP.cm"
           "\n  - {dir}/other/RNaseP_arch.cm"
           "\n  - {dir}/other/beta_tmRNA.cm"
           "\n  - {dir}/other/RNaseP_bact_a.cm"
           "\n  - {dir}/other/cyano_tmRNA.cm"
           "\n  - {dir}/other/RNaseP_bact_b.cm"
           "\n  - {dir}/other/Dictyostelium_SRP.cm"
           "\n  - {dir}/other/RNase_P.cm"
           "\n  - {dir}/other/Fungi_SRP.cm"
           "\n  - {dir}/other/RNaseP_nuc.cm"
           "\n  - {dir}/other/Metazoa_SRP.cm"
           "\n  - {dir}/other/tmRNA.cm"
           "\n  - {dir}/other/mt-tmRNA.cm"
           "\n  - {dir}/other/tRNA.cm"
           "\n  - {dir}/other/tRNA-Sec.cm"
           .format(dir=dir))


def unite_db(file_yml, dir):
    file_yml.write("\n\nunite_db:"
            "\n  class: File\n  path: {dir}/UNITE/unite.fasta\n  checksum: ddb2105cb1f1ffa8941b44c19022b5a3\n"
                   "  format: edam:format_1929\n"
                   "unite_tax: {dir}/UNITE/UNITE-tax.txt\n"
                   "unite_otu_file: {dir}/UNITE/UNITE.otu\n"
                   .format(dir=dir))


def itsone_db(file_yml, dir):
    file_yml.write("\n\nitsonedb:"
            "\n  class: File\n  path: {dir}/ITSonedb/itsonedb.fasta\n  checksum: ec369f9fe6818482ce0ab184461ac116\n"
                   "  format: edam:format_1929\n"
                   "itsonedb_tax: {dir}/ITSonedb/ITSonedb-tax.txt\n"
                   "itsonedb_otu_file: {dir}/ITSonedb/ITSonedb.otu\n"
                   .format(dir=dir))


def other_rna(file_yml):
    file_yml.write("\n\nother_ncrna_models:\n  "
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
                               "rfam_model_clans: {dir}/rRNA.claninfo\n".format(dir=args.dir))
                # other RNA
                other_rna(file_yml)

                # CGC
                file_yml.write("\n"
                           "CGC_postfixes:\n  - '_CDS.faa'\n  - '_CDS.ffn'\n"
                               "cgc_chunk_size: 100000")

                # functional annotation
                file_yml.write("\n"
                           "protein_chunk_size_hmm: 50000\n"
                               "protein_chunk_size_IPS: 10000\n"
                               "protein_chunk_size_eggnog: 100000\n"
                           "func_ann_names_ips: .I5.tsv.without_header\n"
                           "func_ann_names_hmmscan: .hmm.tsv.without_header\n")
                # hmmer
                file_yml.write("\n"
                           "HMMSCAN_gathering_bit_score: true\n"
                           "HMMSCAN_omit_alignment: true\n"
                           "HMMSCAN_name_database: {dir}/db_kofam/db_kofam.hmm\n".format(dir=args.dir))
                file_yml.write("\nhmmsearch_header: 'query_name\tquery_accession\ttlen\ttarget_name\ttarget_accession\tqlen"
                               "\tfull_sequence_e-value\tfull_sequence_score\tfull_sequence_bias\t#\tof\tc-evalue"
                               "\ti-evalue\tdomain_score\tdomain_bias\thmm_coord_from\thmm_coord_to\tali_coord_from"
                               "\tali_coord_to\tenv_coord_from\tenv_coord_to\tacc\tdescription_of_target'")
                # IPS
                file_yml.write("\n"
                               "InterProScan_applications:\n  - PfamA\n  - TIGRFAM\n  - PRINTS\n  - PrositePatterns\n"
                               "  - Gene3d\n"
                               "InterProScan_outputFormat:\n  - TSV\n"
                               "InterProScan_databases: {dir}/interproscan-{ips}/data\n"
                               "ips_header: 'protein_accession\tsequence_md5_digest\tsequence_length\tanalysis"
                               "\tsignature_accession\tsignature_description\tstart_location\tstop_location\tscore"
                               "\tstatus\tdate\taccession\tdescription\tgo\tpathways_annotations'"
                               .format(dir=args.dir, ips=IPS_VERSION))

                if args.type == 'assembly':
                # ===== only assembly =====
                    print('assembly')
                    file_yml.write("\ncontig_min_length: 500\n")

                    # eggnog
                    file_yml.write("\nEggNOG_db: {dir}/eggnog/eggnog.db\n"
                                   "EggNOG_diamond_db: {dir}/eggnog/eggnog_proteins.dmnd\n"
                                   "EggNOG_data_dir: {dir}/eggnog/".format(dir=args.dir))
                    # diamond
                    file_yml.write("\n\nUniref90_db_txt: {dir}/diamond/db_uniref90_{uniref}.txt\n"
                           "diamond_maxTargetSeqs: 1\n"
                           "diamond_databaseFile: {dir}/diamond/uniref90_{uniref}_diamond-v{diamond}.dmnd\n"
                        "diamond_header: 'uniref90_ID\tcontig_name\tpercentage_of_identical_matches\tlenght\tmismatch"
                                   "\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore\tprotein_name"
                                   "\tnum_in_cluster\ttaxonomy\ttax_id\trep_id'"
                                   .format(dir=args.dir, uniref=UNIREF_VERSION, diamond=DIAMOND_VERSION))

                    # pathways
                    file_yml.write("\n\ngraphs: {dir}/kegg_pathways/graphs.pkl\n"
                                   "pathways_names: {dir}/kegg_pathways/all_pathways_names.txt\n"
                                   "pathways_classes: {dir}/kegg_pathways/all_pathways_class.txt"
                                   .format(dir=args.dir))
                    # antismash
                    file_yml.write("\n\nclusters_glossary: {dir}/antismash_glossary.tsv\n".format(dir=args.dir))
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
                                "rfam_model_clans: {dir}/ribosomal/ribo.claninfo\n".format(dir=args.dir))
                # UTINE
                unite_db(file_yml, args.dir)
                # ITSoneDB
                itsone_db(file_yml, args.dir)
        file_yml.close()
        print('---------> yml done')