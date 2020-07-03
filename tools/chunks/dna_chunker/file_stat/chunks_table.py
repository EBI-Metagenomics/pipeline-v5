#!/usr/bin/env python3

import argparse
import sys
from Bio import SeqIO
import os

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Split to chunks")
    #parser.add_argument("-i", "--input", dest="input", help="Whole input fasta file", required=True)
    parser.add_argument("-c", "--chunks", dest="chunks", help="chunk files", nargs='+', required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        final_table = '\t'.join(['chunk_file', 'contig_name', 'position_in_chunk_file']) + '\n'
        args = parser.parse_args()
        for fasta in args.chunks:
            num = 0
            for record in SeqIO.parse(fasta, 'fasta'):
                line = '\t'.join([os.path.basename(fasta), record.name, str(num)])
                num += 1
                final_table += line + '\n'
    print(final_table)
