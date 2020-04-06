#!/usr/bin/env /hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda3-4.6.14/bin/python3
import glob
import argparse
import sys
import os
from Bio import SeqIO
import gzip
import shutil


def get_avg_length(masked_its):  # get average length of longest ITS sequences - separated by 'N'
    if os.path.exists(masked_its):
        all_lengths = []
        with gzip.open(masked_its, 'rt') as unzipped_file:
            for record in SeqIO.parse(unzipped_file, 'fasta'):
                sequences = [x for x in record.seq.split('N') if x and x != '']
                longest_seq = {'num': 0, 'letters': ''}
                for seq in sequences:
                    length = len(seq)
                    if length > longest_seq['num']:
                        longest_seq['num'] = length
                        longest_seq['letters'] = seq
                all_lengths.append(longest_seq['num'])
        return int(sum(all_lengths) / len(all_lengths))
    else:
        return 0


def hits_to_num_ratio(fasta, input_folder):  # ratio of mapseq hits to number of total seqs LSU/SSU
    rna_sum, rna_num = [0 for _ in range(2)]
    rna = os.path.join(input_folder, '*.tsv')
    with open(glob.glob(rna)[0], 'r') as rna_hits:
        for line in rna_hits:
            if not line.startswith('#'):
                rna_sum += float(line.split('\t')[1])
    if 'empty' not in os.path.relpath(fasta):
        rna_num = len([1 for line in gzip.open(fasta, 'rt') if line.startswith('>')])
        return float(rna_sum / rna_num)
    else:
        return 0


def validate_hits(ssu_fasta, lsu_fasta, ssu_folder, lsu_folder, len_avg):  # check length and ratio and assign tag
    ssu_ratio = hits_to_num_ratio(ssu_fasta, ssu_folder)
    lsu_ratio = hits_to_num_ratio(lsu_fasta, lsu_folder)
    if len_avg > 200:
        if ssu_ratio or lsu_ratio > 0.1:
            return 'both'
        else:
            return 'ITS'
    elif 120 <= len_avg <= 199:
        ssu_ratio = hits_to_num_ratio(ssu_fasta, ssu_folder)
        lsu_ratio = hits_to_num_ratio(lsu_fasta, lsu_folder)
        if ssu_ratio or lsu_ratio > 0.1:
            return 'rRNA'
        else:
            return 'ITS'
    else:
        return 'rRNA'


def suppress_dir(flag, lsu, ssu, its, its_file, ssu_file, lsu_file):
    suppressed_folder, taxonomy_summary, its_filename, lsu_filename, ssu_filename = \
        [x for x in ['suppressed', 'taxonomy-summary', os.path.basename(its_file), os.path.basename(lsu_file), os.path.basename(ssu_file)]]
    os.mkdir('suppressed')
    os.mkdir('taxonomy-summary')
    # move dir by tag
    if flag == 'ITS':
        [shutil.copytree(src, dest) for src, dest in [(lsu, suppressed_folder + '/LSU'), (ssu, suppressed_folder + '/SSU'), (its, taxonomy_summary + '/its')]]
        [shutil.copy(src, dest) for src, dest in [(lsu_file, suppressed_folder), (ssu_file, suppressed_folder), (its_file, its_filename)]]
    elif flag == 'rRNA':
        [shutil.copytree(src, dest) for src, dest in [(lsu, taxonomy_summary + '/LSU'), (ssu, taxonomy_summary + '/SSU'), (its, suppressed_folder + '/its')]]
        [shutil.copy(src, dest) for src, dest in [(lsu_file, lsu_filename), (ssu_file, ssu_filename), (its_file, suppressed_folder)]]
    elif flag == 'both':
        [shutil.copytree(src, taxonomy_summary + dest) for src, dest in [(lsu, '/LSU'), (ssu, '/SSU'), (its, '/its')]]
        [shutil.copy(src, dest) for src, dest in [(lsu_file, lsu_filename), (ssu_file, ssu_filename), (its_file, its_filename)]]


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="get average length of ITS sequences and suppress unwanted folders")
    parser.add_argument("--lsu-file", dest="lsu_file", help="lsu fasta")
    parser.add_argument("--ssu-file", dest="ssu_file", help="ssu fasta")
    parser.add_argument("--its-file", dest="its_file", help="its fasta")
    parser.add_argument("--lsu-dir", dest="lsu_directory", help="directory in path taxonomy-summary/LSU")
    parser.add_argument("--ssu-dir", dest="ssu_directory", help="directory in path taxonomy-summary/SSU")
    parser.add_argument("--its-dir", dest="its_directory", help="directory in path taxonomy-summary/its")


    if len(sys.argv) < 6:
        parser.print_help()
    else:
        args = parser.parse_args()
        avg = get_avg_length(args.its_file)
        print('average ITS length is ' + str(avg))
        validate_hits(args.ssu_file, args.lsu_file, args.ssu_directory, args.lsu_directory, avg)
        print('suppressing...')
        suppress_flag = validate_hits(args.ssu_file, args.lsu_file, args.ssu_directory, args.lsu_directory, avg)
        suppress_dir(suppress_flag, args.lsu_directory, args.ssu_directory, args.its_directory, args.its_file, args.ssu_file, args.lsu_file)

