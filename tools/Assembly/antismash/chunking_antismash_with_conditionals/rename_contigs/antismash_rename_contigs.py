#!/usr/bin/env /hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda3-4.6.14/bin/python3


import argparse
import sys
from Bio import SeqIO
import os
import pickle

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
        dict_with_new_names = {}
        new_filename = 'antismash.' + os.path.basename(fasta)
        with open(new_filename, 'w') as new_chunk_file:
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
                dict_with_new_names[new_name] = name_contig
        with open(os.path.basename(fasta)+'.pkl', 'wb') as f:
            pickle.dump(dict_with_new_names, f)
