#!/usr/bin/env /hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda3-4.6.14/bin/python3


import argparse
import sys
from Bio import SeqIO

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="change embl file")
    parser.add_argument("-i", "--input", dest="input", help="embl input file", required=True)
    parser.add_argument("-e", "--embl", dest="embl", help="embl output filename", required=True)
    parser.add_argument("-g", "--gbk", dest="gbk", help="gbk output filename", required=True)
    parser.add_argument("-t", "--table", dest="table", help="table with original and short names", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        dict_names = {}
        with open(args.table, 'r') as table_file:
            for line in table_file:
                line = line.strip().split('\t')
                dict_names[line[0]] = line[1]
        with open(args.embl, 'w') as new_embl, open(args.gbk, 'w') as new_gbk:
            for record in SeqIO.parse(args.input, "embl"):
                name = record.id
                description = dict_names[name]
                record.description = description
                for feature in record.features:
                    if 'locus_tag' in feature.qualifiers:
                        number = feature.qualifiers['locus_tag'][0].split('_')[1]
                        feature.qualifiers['locus_tag'] = [name + '_' + number]
                SeqIO.write(record, new_embl, "embl")
                SeqIO.write(record, new_gbk, "gb")

