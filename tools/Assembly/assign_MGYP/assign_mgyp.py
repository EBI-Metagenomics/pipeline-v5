#!/usr/bin/env python3

import argparse
import sys
import os
from datetime import datetime
from Bio import SeqIO
import json
import re
import hashlib
import stat
import fcntl


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--fasta', dest='fasta', required=True, help='Fasta file with proteins')
    parser.add_argument('-c', '--config', dest='config', required=True, help='path to mapping dir')
    parser.add_argument("-a", "--accession", help="run accession", dest="accession", required=True)
    parser.add_argument("-p", "--previous", help="previous mapping files", dest="prev_mapping", required=False)
    parser.add_argument("-r", "--release", help="release name where to write new accessions", dest="release", required=True)
    return parser
"""
-f test.fasta 
-c new_config
    mapping: /nfs/production/interpro/metagenomics/peptide_db/mapping 
    releases: /nfs/production/interpro/metagenomics/peptide_db/releases
-p /nfs/production/interpro/metagenomics/peptide_db/mapping/mgyp/20200723
-a ERZ*** \
-r 20200723 or another date

Read data from previous, write data to mapping/mgyp/release
"""



def prev_processing(releases, type, new_release_number):
    # Define previous mapping directory by the closest date
    prev_mappings = []
    mapping_dir = os.path.join(releases, type)
    for pv in sorted(os.listdir(mapping_dir), reverse=True):
        if re.match('^\d{8}$', pv) and pv != new_release_number:
            prev_mappings.append(pv)
    if prev_mappings:
        last_map = prev_mappings[0]
    else:
        last_map = None
    prev_mapping_dir = os.path.join(releases, type, last_map)
    return prev_mapping_dir


def get_bioms(mapping):
    biome_file = os.path.join(mapping, 'biome', 'all-biomes.txt')
    biome = {}
    with open(biome_file) as bfh:
        for line in bfh:
            acc, b = line.rstrip().split('\t')
            biome[acc] = b
    print('Biome', len(biome))
    return biome


def next_accession(filename):
    fd = open(filename, 'r+')
    fcntl.lockf(fd, fcntl.LOCK_EX)
    max = fd.read()
    next_acc = int(max) + 1
    print('Start with accession number ', next_acc)
    fd.seek(0)
    fd.truncate()
    return next_acc, fd


def read_map_file(file):
    map = {}
    if not os.path.exists(file):
        return map
    with open(file) as fh:
        for line in fh:
            seq, partial, acc = line.rstrip().split(' ')
            if not seq in map:
                map[seq] = {}
            map[seq][partial] = acc
    print('Length of already existing map-file: ', len(map))
    return map


def create_digest(seq):
    dtype = 'sha256'
    h = hashlib.new(dtype)
    h.update(seq.encode('utf-8'))
    digest = h.hexdigest()
    return digest


def map_accessions(seq, partial, map, next_acc, biome, obs_biome, assembly, update, file_hash):
    if seq in map and partial in map[seq]:
        acc = map[seq][partial]
    elif seq in map:
        acc = "MGYP%012d" % next_acc
        next_acc += 1
        map[seq][partial] = acc
    else:
        acc = "MGYP%012d" % next_acc
        next_acc += 1
        map[seq] = {}
        map[seq][partial] = acc

    if assembly in biome:
        b = biome[assembly]
    else:
        b = ''
    if not b in obs_biome:
        obs_biome[b] = 0
    obs_biome[b] += 1
    if update:
        print('update map file')
        file_hash.write(' '.join([seq, partial, acc]) + '\n')
    return next_acc, acc


def create_peptides_file(peptides, accession):
    folder = os.path.join(peptides, accession[:7])
    if not os.path.exists(folder):
        os.mkdir(folder)
    subfolder = os.path.join(folder, accession)
    if not os.path.exists(subfolder):
        os.mkdir(subfolder)
    peptides_file = os.path.join(subfolder, 'peptides.txt')
    return peptides_file


def parsing_header(header):
    if 'partial' in header:
        # prodigal header
        caller = 'Prodigal'
        start_coordinate, stop_coordinate, strand = re.findall(r"#\s(.*?)\s", header)
        id, partial, start_type, stop_type, rbs_motif = re.findall(r"\=(.*?)\;", header)
    else:
        #FGS header
        partial = '11'
        caller = 'FGS'
        list_fields = header.split('_')
        length = len(list_fields)
        sign_strand, stop_coordinate, start_coordinate = list_fields[length-1], list_fields[length-2], list_fields[length-3]
        strand = str(int(sign_strand + '1'))
    return partial, start_coordinate, stop_coordinate, strand, caller


if __name__ == "__main__":

    TYPE = 'mgyp'
    args = get_args().parse_args()
    with open(args.config, 'r') as fc:
        config = json.loads(fc.read())
        mapping_dir = config['mapping']
        releases_dir = config['releases']
        max_pep_length = config['max_pep_length']
        peptides = config['peptides']
        if not os.path.exists(peptides): os.mkdir(peptides)

    # define previous mapping files
    prev_mapping_dir = args.prev_mapping if args.prev_mapping else prev_processing(releases_dir, TYPE, args.release)
    print('Previous mapping dir: ', prev_mapping_dir)
    # define current mapping directory
    cur_mapping_dir = os.path.join(mapping_dir, TYPE, args.release)
    if not os.path.exists(cur_mapping_dir): os.mkdir(cur_mapping_dir)
    print('Current mapping dir: ', cur_mapping_dir)

    if os.path.basename(prev_mapping_dir) == args.release:
        # will map in the same dir -> add lines to files
        update = True
    else:
        # will generate map files from scratch in new directory
        update = False

    biome = get_bioms(mapping_dir)

    # Read the last given accession number
    file_next_accession = os.path.join(prev_mapping_dir, 'max_acc')
    next_acc, fd = next_accession(file_next_accession)

    # create new files and read maps from the last release
    files_hash = {}
    set_twochar = []
    for twochar in [hex(x)[2:] + hex(y)[2:] for x in range(16) for y in range(16)]:
        set_twochar.append(twochar)
        cur_filename = os.path.join(cur_mapping_dir, twochar)
        if update:
            print('Will update existing twochar files')
            files_hash[twochar] = open(cur_filename, 'a')  # open file to add lines in the end
        else:
            print('Will create new twochar files')
            files_hash[twochar] = open(cur_filename, 'w')  # open file to write from scratch
        print('Block ', twochar)
        fcntl.lockf(files_hash[twochar], fcntl.LOCK_EX)

    obs_biome = {}
    dict_hash_records = {}
    long_peptides = 0
    peptides_file = create_peptides_file(peptides, args.accession)
    # read fasta file, create digests
    for record in SeqIO.parse(args.fasta, "fasta"):
        if len(record.seq) > max_pep_length: long_peptides += 1
        hash_seq = create_digest(record.seq)
        twochar = hash_seq[:2]
        if twochar not in dict_hash_records:
            dict_hash_records[twochar] = []
        dict_hash_records[twochar].append(record)

    unused_twochar = list(set(set_twochar).difference(set(dict_hash_records.keys())))
    print('unused', len(unused_twochar))

    # read mappings, create new
    with open(peptides_file, 'w') as file_peptides, open(args.accession+'_FASTA.mgyp.fasta', 'w') as new_fasta:
        for twochar in dict_hash_records:
            print('Process ', twochar, 'peptides', len(dict_hash_records[twochar]))
            map = read_map_file(os.path.join(prev_mapping_dir, twochar))
            for record in dict_hash_records[twochar]:
                partial, start_coordinate, stop_coordinate, strand, caller = parsing_header(record.id)
                next_acc, mgy_accession = map_accessions(map=map, next_acc=next_acc, seq=record.seq, biome=biome,
                                                         partial=partial, assembly=args.accession, update=update,
                                                         file_hash=files_hash[twochar], obs_biome=obs_biome)
                file_peptides.write(' '.join([mgy_accession, record.id, start_coordinate, stop_coordinate, strand,
                                              partial, caller]))
                record.id = mgy_accession
            record.description = mgy_accession
            SeqIO.write(record, new_fasta, "fasta")

            if not update:
                print('write map files from scratch')
                for seq_map in map:
                    for partial_map in map[seq_map]:
                        files_hash[twochar].write(' '.join([str(seq_map), str(partial_map),
                                                            str(map[seq_map][partial_map])]))
            print('Unblock', twochar)
            fcntl.lockf(files_hash[twochar], fcntl.LOCK_UN)

    print('Write max_acc, return permissions')
    fd.write(str(next_acc))
    fcntl.lockf(fd, fcntl.LOCK_UN)
    print('Finish with accession number: ', next_acc)

    print('Write ', os.path.join(cur_mapping_dir, 'mgy_biome_counts_' + args.release + '.tsv'))
    with open(os.path.join(cur_mapping_dir, 'mgy_biome_counts_' + args.release + '.tsv'), 'w') as fbiome:
        for b in sorted(obs_biome.items(), key=lambda x: x[1], reverse=True):
            fbiome.write(str(b[1]) + '\t' + b[0] + '\n')

    print('Unblock unused files')
    for twochar in unused_twochar:
        fcntl.lockf(files_hash[twochar], fcntl.LOCK_UN)

# Process hashes first and read mappings on by one