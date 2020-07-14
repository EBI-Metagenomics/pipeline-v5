#!/usr/bin/env python3

import argparse
import sys
from Bio import SeqIO
import os

NAME_LIMIT = 16

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Split to chunks")
    parser.add_argument("-i", "--input", dest="input", help="Whole input fasta file", required=True)
    parser.add_argument("-c", "--chunk", dest="chunk", help="chunk file", required=True)
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
        fasta = args.chunk
        new_filename = 'antismash.' + os.path.basename(fasta)
        with open(new_filename, 'w') as new_chunk_file, open(os.path.basename(fasta)+'.tbl', 'w') as f:
            for record in SeqIO.parse(fasta, 'fasta'):
                name_contig = record.name
                number_contig = contig_dict[name_contig]
                accession = args.accession.split('_')[0]
                limit = min(NAME_LIMIT - 1 - len(number_contig), len(accession)-1)
                new_name = accession[0:limit] + '-' + contig_dict[name_contig]
                new_record = record
                new_record.id = new_name
                new_record.description = new_name
                SeqIO.write(new_record, new_chunk_file, "fasta")
                f.write('\t'.join([new_name, name_contig]) + '\n')
    f.close()
