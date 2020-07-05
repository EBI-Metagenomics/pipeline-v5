#!/usr/bin/env python3

import argparse
import sys
from Bio import SeqIO
import os

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Split to chunks")
    parser.add_argument("-i", "--input", dest="input", help="Whole input fasta file", required=True)
    parser.add_argument("-c", "--chunks", dest="chunks", help="chunk files", nargs='+', required=True)
    parser.add_argument("-a", "--accession", dest="accession", help="accession of run", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        contig_dict = {}
        args = parser.parse_args()
        num = 1
        for record in SeqIO.parse(args.input, 'fasta'):
            contig_dict[record.name] = str(num)
            num += 1
        for fasta in args.chunks:
            new_filename = 'antismash.' + os.path.basename(fasta)
            with open(new_filename, 'w') as new_chunk_file:
                for record in SeqIO.parse(fasta, 'fasta'):
                    name_contig = record.name
                    new_name = args.accession + '-' + contig_dict[name_contig]
                    new_record = record
                    new_record.id = new_name
                    new_record.description = new_name
                    SeqIO.write(new_record, new_chunk_file, "fasta")
