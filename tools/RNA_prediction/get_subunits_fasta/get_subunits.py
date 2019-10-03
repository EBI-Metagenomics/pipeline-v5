#!/usr/bin/env python3

import argparse
import sys
import os
import gzip
from Bio import SeqIO

directory = "sequence-categorisation"
if not os.path.exists(directory): os.makedirs(directory)

SSU_rRNA_archaea = "SSU_rRNA_archaea"
SSU_rRNA_bacteria = "SSU_rRNA_bacteria"
SSU_rRNA_eukarya = "SSU_rRNA_eukarya"

LSU_rRNA_archaea = "LSU_rRNA_archaea"
LSU_rRNA_bacteria = "LSU_rRNA_bacteria"
LSU_rRNA_eukarya = "LSU_rRNA_eukarya"

LSU_filename = directory + "/LSU.fasta"
SSU_filename = directory + "/SSU.fasta"
FiveS_filename = directory + "/5S.fasta"
FiveEightS_filename = directory + "/5_8S.fasta"


def set_model_names(prefix):

    SSU_rRNA_archaea_name = directory + "/" + prefix + '_' + SSU_rRNA_archaea + '.RF01959.fa'
    SSU_rRNA_bacteria_name = directory + "/" + prefix + '_' + SSU_rRNA_bacteria + '.RF00177.fa'
    SSU_rRNA_eukarya_name = directory + "/" + prefix + '_' + SSU_rRNA_eukarya + '.RF01960.fa'
    LSU_rRNA_archaea_name = directory + "/" + prefix + '_' + LSU_rRNA_archaea + '.RF02540.fa'
    LSU_rRNA_bacteria_name = directory + "/" + prefix + '_' + LSU_rRNA_bacteria + '.RF02541.fa'
    LSU_rRNA_eukarya_name = directory + "/" + prefix + '_' + LSU_rRNA_eukarya + '.RF02543.fa'

    return [SSU_rRNA_archaea_name, SSU_rRNA_bacteria_name, SSU_rRNA_eukarya_name, \
           LSU_rRNA_archaea_name, LSU_rRNA_bacteria_name, LSU_rRNA_eukarya_name]


def open_model_files(names):

    SSU_a_out = open(names[0], 'wt')
    SSU_b_out = open(names[1], 'wt')
    SSU_e_out = open(names[2], 'wt')

    LSU_a_out = open(names[3], 'wt')
    LSU_b_out = open(names[4], 'wt')
    LSU_e_out = open(names[5], 'wt')
    return SSU_a_out, SSU_b_out, SSU_e_out, LSU_a_out, LSU_b_out, LSU_e_out


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Extract lsu, ssu and 5s")
    parser.add_argument("-i", "--input", dest="input", help="Input fasta file", required=True)
    parser.add_argument("-l", "--lsu", dest="lsu", help="LSU pattern", required=True)
    parser.add_argument("-s", "--ssu", dest="ssu", help="SSU pattern", required=True)

    parser.add_argument("-f", "--fives", dest="fives", help="5S pattern")
    parser.add_argument("-e", "--five_eights", dest="five_eights", help="5.8S pattern")
    parser.add_argument("-p", "--prefix", dest="prefix", help="prefix for models")

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()

        print('Start fasta mode')
        out_ssu = open(SSU_filename, 'wt')
        out_lsu = open(LSU_filename, 'wt')
        out_5S = open(FiveS_filename, 'wt')
        out_5_8S = open(FiveEightS_filename, 'wt')

        names = set_model_names(args.prefix)

        SSU_a_out, SSU_b_out, SSU_e_out, LSU_a_out, LSU_b_out, LSU_e_out = open_model_files(names)

        for record in SeqIO.parse(args.input, "fasta"):

            if args.lsu in record.id:
                SeqIO.write(record, out_lsu, "fasta")
            elif args.ssu in record.id:
                SeqIO.write(record, out_ssu, "fasta")
            elif args.fives in record.id:
                SeqIO.write(record, out_5S, "fasta")
            elif args.five_eights in record.id:
                SeqIO.write(record, out_5_8S, "fasta")

            if SSU_rRNA_archaea in record.id:
                SeqIO.write(record, SSU_a_out, "fasta")
            elif SSU_rRNA_bacteria in record.id:
                SeqIO.write(record, SSU_b_out, "fasta")
            elif SSU_rRNA_eukarya in record.id:
                SeqIO.write(record, SSU_e_out, "fasta")
            elif LSU_rRNA_archaea in record.id:
                SeqIO.write(record, LSU_a_out, "fasta")
            elif LSU_rRNA_bacteria in record.id:
                SeqIO.write(record, LSU_b_out, "fasta")
            elif LSU_rRNA_eukarya in record.id:
                SeqIO.write(record, LSU_e_out, "fasta")

        out_5S.close()
        out_5_8S.close()
        SSU_a_out.close()
        SSU_b_out.close()
        SSU_e_out.close()
        LSU_a_out.close()
        LSU_b_out.close()
        LSU_e_out.close()

        # remove empty files
        for onefile in [FiveS_filename, FiveEightS_filename] + names:
            if os.path.getsize(onefile) == 0:
                os.remove(onefile)

        # remove directory if it's empty ??

    out_ssu.close()
    out_lsu.close()
