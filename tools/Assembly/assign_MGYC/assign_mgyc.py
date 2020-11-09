#!/usr/bin/env python3

import argparse
import os
from Bio import SeqIO
import hashlib
from oslo_concurrency import lockutils
import _pickle as cPickle
import gzip
import json


def get_args():
    parser = argparse.ArgumentParser(description="create file with MGYCs for run")
    parser.add_argument('-f', '--fasta', dest='fasta', required=True, help='Fasta file with original contig names')
    parser.add_argument('-m', '--mapping', dest='mapping', required=True, help='config')
    parser.add_argument("-c", "--count", help="number of sequences in fasta file", dest="count", required=True)
    parser.add_argument("-a", "--accession", help="run accession", dest="accession", required=True)
    parser.add_argument("-s", "--study", help="study accession", dest="study", required=True)
    parser.add_argument("--path-fasta", help="generate mgyc.fasta in assembly_peptides folder", required=False,
                        action='store_true')
    parser.add_argument("--save-json", help="Save table to json", action='store_true', required=False)
    return parser


def write_next_acc(filename, path_lock, count):
    with lockutils.lock(filename+'.lock', lock_path=path_lock, external=True):
        print('Locking max_acc file ...')
        filepath = os.path.join(path_lock, filename)
        try:
            fd = open(filepath, 'r+')
            max = fd.read()
            next_acc = int(max) + 1
            print('Start with accession number ', next_acc)
            fd.seek(0)
            fd.truncate()
            fd.write(str(next_acc + int(count) - 1))
        except IOError:
            os._exit(2)
        finally:
            fd.close()
    print('Finish with accession number: ', next_acc + int(count) - 1)
    return next_acc


def create_digest(seq):
    #digest = hashlib.new('sha256').update(seq.encode('utf-8')).hexdigest()
    digest = hashlib.sha256(str(seq).encode('utf-8')).hexdigest()
    return digest


def get_length(header):
    line = header.split('-')
    for item in range(len(line)-1):
        if line[item] == 'length':
            return line[item+1]
    return 0


def get_kmercoverage(header):
    line = header.split('-')
    for item in range(len(line)):
        if line[item] == 'cov':
            return line[item+1]
    return 0


def open_fasta(filename):
    if filename.endswith('.gz'):
        return gzip.open(filename, 'rt')
    else:
        return open(filename, 'r')


if __name__ == "__main__":

    TYPE = 'mgyc'
    args = get_args().parse_args()
    accession = args.accession
    with open(args.mapping, 'r') as fc:
        config = json.loads(fc.read())
        assembly_peptides_dir = config['peptides']
        max_acc_dir = os.path.join(config['max_acc'], TYPE)
    print('max_acc file ', max_acc_dir)
    print('Run: ' + accession)
    mapping_dir = os.path.join(assembly_peptides_dir, args.study, accession)
    os.makedirs(mapping_dir, exist_ok=True)
    print('map-file ', mapping_dir)
    # update number
    next_acc = write_next_acc(filename='max_acc', path_lock=max_acc_dir, count=args.count)

    if args.path_fasta:
        new_fasta_name = os.path.join(mapping_dir, accession + '_FASTA.mgyc.fasta')
    else:
        new_fasta_name = accession + '_FASTA.mgyc.fasta'

    file_with_mgyc = os.path.join(mapping_dir, accession+'.mgyc.txt')
    # read fasta file, create digests, change contig names
    dict_contig = {}  # { contig_name: accession }
    with open(new_fasta_name, 'w') as new_fasta, open(file_with_mgyc, 'w') as accession_file:
        input_fasta_file = open_fasta(args.fasta)
        for record in SeqIO.parse(input_fasta_file, "fasta"):
            length = str(get_length(record.id))
            kmer_covarage = str(get_kmercoverage(record.id))
            mgy_accession = "MGYC%012d" % next_acc
            hash_seq = create_digest(str(record.seq))
            hash_erz_seq = create_digest(accession + record.seq)
            next_acc += 1
            accession_file.write(' '.join([mgy_accession, hash_erz_seq, hash_seq, length, kmer_covarage]) + '\n')
            dict_contig[record.id] = mgy_accession
            record.id = mgy_accession
            record.description = mgy_accession
            SeqIO.write(record, new_fasta, "fasta")
    if args.save_json:
        filepath = os.path.join(mapping_dir, accession)
        with open(filepath + '.mgyc.json', 'w') as json_file:
            json.dump(dict_contig, json_file)

