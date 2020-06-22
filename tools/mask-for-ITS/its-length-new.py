#!/usr/bin/python3
import glob
import argparse
import sys
import os
from Bio import SeqIO
import gzip
import shutil


def get_avg_length(masked_its):  # get average length of longest ITS sequences - separated by 'N'
    if masked_its is not None:
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
    else:
        return 0


def hits_to_num_ratio(fasta, input_folder):  # ratio of mapseq hits to number of total seqs LSU/SSU
    rna_sum, rna_num = [0 for _ in range(2)]
    rna = os.path.join(input_folder, '*.tsv')
    if 'empty' not in os.path.relpath(fasta):
        with open(glob.glob(rna)[0], 'r') as rna_hits:
            for line in rna_hits:
                if not line.startswith('#'):
                    rna_sum += float(line.split('\t')[1])
        rna_num = len([1 for line in gzip.open(fasta, 'rt') if line.startswith('>')])
        return float(rna_sum / rna_num)
    else:
        return 0


def validate_hits(ssu_fasta, lsu_fasta, ssu_folder, lsu_folder, len_avg):  # check length and ratio and assign tag
    ssu_ratio = hits_to_num_ratio(ssu_fasta, ssu_folder) if ssu_folder is not None else 0
    lsu_ratio = hits_to_num_ratio(lsu_fasta, lsu_folder) if lsu_folder is not None else 0
    if len_avg > 200:
        if ssu_ratio or lsu_ratio > 0.1:
            return 'both'
        else:
            return 'ITS'
    elif 120 <= len_avg <= 199:
        if ssu_ratio or lsu_ratio > 0.1:
            return 'rRNA'
        else:
            return 'ITS'
    else:
        return 'rRNA'


def suppress_dir(flag, lsu, ssu, its, its_file, ssu_file, lsu_file):
    suppressed_folder = 'suppressed'
    os.mkdir('suppressed')
    taxonomy_summary = 'taxonomy-summary'
    os.mkdir('taxonomy-summary')

    its_filename = os.path.basename(its_file) if its is not None else ''
    lsu_filename = os.path.basename(lsu_file) if lsu is not None else ''
    ssu_filename = os.path.basename(ssu_file) if ssu is not None else ''

    # move dir by tag
    list_folders, list_files = [[] for _ in range(2)]
    addition = ''
    for folder, name, cur_file, filename in zip([lsu, ssu, its],
                                                ['/LSU', '/SSU', '/its'],
                                                [lsu_file, ssu_file, its_file],
                                                [lsu_filename, ssu_filename, its_filename]):
        if folder is not None:
            if flag == 'ITS':
                if name == '/its':
                    list_folders.append((folder, taxonomy_summary + name))
                    list_files.append((cur_file, filename))
                else:
                    list_folders.append((folder, suppressed_folder + name))
                    list_files.append((cur_file, suppressed_folder))
            elif flag == 'rRNA':
                if name == '/its':
                    list_folders.append((folder, suppressed_folder + name))
                    list_files.append((cur_file, suppressed_folder))
                else:
                    list_folders.append((folder, taxonomy_summary + name))
                    list_files.append((cur_file, filename))
            elif flag == 'both':
                list_folders.append((folder, name))
                list_files.append((cur_file, filename))
                addition = taxonomy_summary

    [shutil.copytree(src, addition + dest) for src, dest in list_folders]
    [shutil.copy(src, dest) for src, dest in list_files]


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="get average length of ITS sequences and suppress unwanted folders")
    parser.add_argument("--lsu-file", dest="lsu_file", help="lsu fasta", required=False, default=None)
    parser.add_argument("--ssu-file", dest="ssu_file", help="ssu fasta", required=False, default=None)
    parser.add_argument("--its-file", dest="its_file", help="its fasta", required=False, default=None)
    parser.add_argument("--lsu-dir", dest="lsu_directory", help="directory in path taxonomy-summary/LSU",
                        required=False, default=None)
    parser.add_argument("--ssu-dir", dest="ssu_directory", help="directory in path taxonomy-summary/SSU",
                        required=False, default=None)
    parser.add_argument("--its-dir", dest="its_directory", help="directory in path taxonomy-summary/its",
                        required=False, default=None)


    if len(sys.argv) < 3:
        parser.print_help()
    else:
        args = parser.parse_args()
        avg = get_avg_length(args.its_file)
        print('average ITS length is ' + str(avg))
        print('suppressing...')
        suppress_flag = validate_hits(args.ssu_file, args.lsu_file, args.ssu_directory, args.lsu_directory, avg)
        print(suppress_flag)
        suppress_dir(suppress_flag, args.lsu_directory, args.ssu_directory, args.its_directory, args.its_file,
                     args.ssu_file, args.lsu_file)
        if len(os.listdir('suppressed')) == 0:
            os.rmdir('suppressed')
        if len(os.listdir('taxonomy-summary')) == 0:
            os.rmdir('taxonomy-summary')