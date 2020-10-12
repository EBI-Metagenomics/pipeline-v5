#!/usr/bin/env python3

import argparse
import os
from Bio import SeqIO
import hashlib
from oslo_concurrency import lockutils


def get_args():
    parser = argparse.ArgumentParser(description="create file with MGYCs for run")
    parser.add_argument('-f', '--fasta', dest='fasta', required=True, help='Fasta file with original contig names')
    parser.add_argument('-m', '--mapping', dest='mapping', required=True, help='folder to save MGYCs')
    parser.add_argument("-c", "--count", help="number of sequences in fasta file", dest="count", required=True)
    parser.add_argument("-a", "--accession", help="run accession", dest="accession", required=True)
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
    #dtype = 'sha256'
    #h = hashlib.new(dtype)
    #h.update(seq.encode('utf-8'))
    #digest = h.hexdigest()
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


if __name__ == "__main__":

    TYPE = 'mgyc'
    args = get_args().parse_args()
    print('Run: ' + args.accession)
    mapping_dir = os.path.join(args.mapping, TYPE)
    # update number
    next_acc = write_next_acc(filename='max_acc', path_lock=mapping_dir, count=args.count)

    new_fasta_name = args.accession+'_FASTA.mgyc.fasta'
    file_with_mgyc = os.path.join(mapping_dir, args.accession+'.txt')
    # read fasta file, create digests, change contig names
    with open(new_fasta_name, 'w') as new_fasta, open(file_with_mgyc, 'w') as accession_file:
        for record in SeqIO.parse(args.fasta, "fasta"):
            length = get_length(record.id)
            kmer_covarage = get_kmercoverage(record.id)
            mgy_accession = "MGYC%012d" % next_acc
            hash_seq = create_digest(str(record.seq))
            hash_erz_seq = create_digest(args.accession + record.seq)
            next_acc += 1
            accession_file.write(' '.join([mgy_accession, hash_erz_seq, hash_seq, length, kmer_covarage]) + '\n')
            record.id = mgy_accession
            record.description = mgy_accession
            SeqIO.write(record, new_fasta, "fasta")
