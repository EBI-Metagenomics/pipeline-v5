#!/usr/bin/env python3

import argparse
import logging
import os
import gc
import _pickle as cPickle
from Bio import SeqIO
import json
import re
import hashlib
import time
from oslo_concurrency import lockutils


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--fasta', dest='fasta', required=True, help='Fasta file with proteins')
    parser.add_argument('-v', '--verbose', action='store_true')
    parser.add_argument("-a", "--accession", help="run accession", dest="accession", required=True)
    parser.add_argument('-c', '--config', dest='config', required=True, help='path to mapping dir')
    parser.add_argument("-r", "--release", help="release name where to write new accessions", dest="release",
                        required=True)
    parser.add_argument("--private", help="set this option if run is from private request", dest="private",
                        required=False, action='store_true')
    return parser


def get_bioms(mapping):
    biome_file = os.path.join(mapping, 'biome', 'all-biomes.txt')
    biome = {}
    with open(biome_file) as bfh:
        for line in bfh:
            acc, b = line.rstrip().split('\t')
            biome[acc] = b
    logging.info('Biome ' + str(len(biome)))
    return biome


def create_peptides_file(peptides, accession):
    folder = os.path.join(peptides, accession[:7])
    if not os.path.exists(folder):
        os.mkdir(folder)
    subfolder = os.path.join(folder, accession)
    if not os.path.exists(subfolder):
        os.mkdir(subfolder)
    peptides_file = os.path.join(subfolder, 'peptides.txt')
    return peptides_file, subfolder


def create_digest(seq):
    #h = hashlib.new('sha256')
    #digest = h.update(seq.encode('utf-8')).hexdigest()
    digest = hashlib.sha256(str(seq).encode('utf-8')).hexdigest()
    return digest


def read_map_file(file, mode='pickle'):
    start = time.time()
    map = {}
    if not os.path.exists(file):
        return map
    if os.path.exists(file+'.pkl'):
        if mode == 'pickle':
            with open(file+'.pkl', 'rb') as read_file:
                map = cPickle.load(read_file)
        else:
            with open(file) as fh:
                for line in fh:
                    seq, partial, *_ = line.rstrip().split(' ')
                    acc = _[0]
                    public_sign = _[1] if len(_) > 1 else 0
                    if not seq in map:
                        map[seq] = {}
                    map[seq][partial] = [acc, public_sign]
    else:
        with open(file) as fh:
            for line in fh:
                seq, partial, *_ = line.rstrip().split(' ')
                acc = _[0]
                public_sign = _[1] if len(_) > 1 else 0
                if not seq in map:
                    map[seq] = {}
                map[seq][partial] = [acc, public_sign]
    end = time.time()
    return map, end-start


def save_map_file(map, cur_twochar):
    # save as pickle
    start = time.time()
    gc.disable()
    with open(cur_twochar + '.pkl', 'wb') as pickle_file:
        cPickle.dump(map, pickle_file)
    pickle_file.close()
    gc.enable()
    end = time.time()
    logging.debug('Saving took ' + str(end - start) + 's')


def map_accessions(seq, partial, map, next_acc, biome, obs_biome, assembly, public):
    new = True
    if seq in map and partial in map[seq]:
        logging.debug('----------- found seq and partial in map-file')
        acc = map[seq][partial][0]
        new = False
    elif seq in map:
        logging.debug('----------- found only seq in map-file')
        acc = "MGYP%012d" % next_acc
        next_acc += 1
        map[seq][partial] = [acc, public]
    else:
        logging.debug('----------- new protein')
        acc = "MGYP%012d" % next_acc
        next_acc += 1
        map[seq] = {}
        map[seq][partial] = [acc, public]

    if assembly in biome:
        b = biome[assembly]
    else:
        b = ''
    if not b in obs_biome:
        obs_biome[b] = 0
    obs_biome[b] += 1
    return next_acc, acc, new


def parsing_header(header):
    if 'partial' in header:
        # prodigal header
        caller = 'Prodigal'
        start_coordinate, stop_coordinate, strand = re.findall(r"#\s(.*?)\s", header)
        id, partial, start_type, stop_type, rbs_motif = re.findall(r"\=(.*?)\;", header)
    else:
        # FGS header
        partial = '11'
        caller = 'FGS'
        list_fields = header.split('_')
        length = len(list_fields)
        sign_strand, stop_coordinate, start_coordinate = list_fields[length-1], list_fields[length-2], list_fields[length-3]
        strand = str(int(sign_strand + '1'))
    return partial, start_coordinate, stop_coordinate, strand, caller


def update_max_accession(number_new_records, file_next_accession):
    with lockutils.lock('.lock', 'max_acc', lock_path=cur_mapping_dir, external=True):
        try:
            logging.debug('Locking max_acc file ...')
            # Read the last given accession number
            fd = open(file_next_accession, 'r+')
            max = fd.read()
            logging.info('Start with accession number ' + max)
            next_acc = int(max) + number_new_records
            fd.seek(0)
            fd.truncate()
            # write next accession
            fd.write(str(next_acc))
            logging.info('Finish with accession number ' + str(next_acc))
            logging.debug('... Return max_acc file')
        except IOError:
            os._exit(2)
        finally:
            fd.close()
    return int(max)


if __name__ == "__main__":

    TYPE = 'mgyp'
    args = get_args().parse_args()
    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO)
    with open(args.config, 'r') as fc:
        config = json.loads(fc.read())
        mapping_dir = config['mapping']
        max_pep_length = config['max_pep_length']
        peptides = config['peptides']
        if not os.path.exists(peptides): os.mkdir(peptides)
    public_value = 1 if args.private else 0

    peptides_file, peptides_subfolder = create_peptides_file(peptides, args.accession)

    # check mapping dir for existence
    cur_mapping_dir = os.path.join(mapping_dir, TYPE, args.release)
    logging.info('Current mapping directory: ' + str(cur_mapping_dir))
    if not os.path.exists(cur_mapping_dir):
        logging.error("Mapping directory doesn't exist")
        exit(1)

    dict_hash_records, obs_biome, files_hash = [{} for _ in range(3)]
    long_peptides = 0
    used_twochar = []
    # read fasta file, create digests
    for record in SeqIO.parse(args.fasta, "fasta"):
        if len(record.seq) > max_pep_length:
            long_peptides += 1
        hash_seq = create_digest(str(record.seq))
        twochar = hash_seq[:2]
        if twochar not in dict_hash_records:
            dict_hash_records[twochar] = []
        dict_hash_records[twochar].append(record)
    # write long peprides
    with open(os.path.join(peptides_subfolder, 'long-proteins-number.txt'), 'w') as long_file:
        logging.info('Write number of long peptides: ' + str(os.path.join(peptides_subfolder, 'long-proteins-number.txt')))
        long_file.write(str(long_peptides))

    used_twochar = list(dict_hash_records.keys())
    logging.info('Used twochar hashes: ' + str(used_twochar))
    # prepare dict with names
    for twochar in used_twochar:
        files_hash[twochar] = os.path.join(cur_mapping_dir, twochar)

    biome = get_bioms(mapping_dir)

    file_peptides = open(peptides_file, 'w')
    new_fasta = open(args.accession + '_FASTA.mgyp.fasta', 'w')
    logging.info('New FASTA file: ' + args.accession + '_FASTA.mgyp.fasta')

    for twochar in dict_hash_records:
        cur_twochar = files_hash[twochar]
        with lockutils.lock('.lock', cur_twochar, lock_path=os.path.dirname(cur_twochar), external=True):
            # read existing map-file
            mapping_dir_release = os.path.join(mapping_dir, TYPE, args.release, twochar)
            logging.debug('---> Reading map file from ' + str(mapping_dir_release))
            map, reading_time = read_map_file(mapping_dir_release)
            logging.info('Process:' + twochar + ', peptides:' + str(len(dict_hash_records[twochar])) +
                         ', size of map: ' + str(len(map)) + ', reading time: ' + str(reading_time) + 's')

            # find new records for map file
            new_records = []
            for record in dict_hash_records[twochar]:
                partial, start_coordinate, stop_coordinate, strand, caller = parsing_header(record.id)
                if not (record.seq in map and partial in map[record.seq]):
                    new_records.append(record)

            # update accessions-file
            file_next_accession = os.path.join(cur_mapping_dir, 'max_acc')
            cur_accession = update_max_accession(len(new_records), file_next_accession)
            try:
                file_desc_twochar = open(cur_twochar, 'r+')
                # adding all proteins
                logging.debug('-----> processing map-file')
                for record in dict_hash_records[twochar]:
                    partial, start_coordinate, stop_coordinate, strand, caller = parsing_header(record.id)
                    cur_accession, mgy_accession, new_protein_flag = map_accessions(map=map, next_acc=cur_accession,
                                                                                    seq=record.seq, biome=biome,
                                                            partial=partial, assembly=args.accession,
                                                            obs_biome=obs_biome, public=public_value)
                    # write table of protein data
                    file_peptides.write(' '.join([mgy_accession, record.id, start_coordinate, stop_coordinate, strand,
                                                  partial, caller]))
                    record.id = mgy_accession
                    record.description = mgy_accession
                    # write fasta file with new accessions
                    SeqIO.write(record, new_fasta, "fasta")
                save_map_file(map, cur_twochar)
            except IOError:
                os._exit(2)
            finally:
                file_desc_twochar.close()
            logging.debug('-----> Check final accession: ' + str(cur_accession))

    logging.info('Write biom counts ' + str(os.path.join(cur_mapping_dir, 'mgy_biome_counts_' + args.release + '.tsv')))
    with open(os.path.join(cur_mapping_dir, 'mgy_biome_counts_' + args.release + '.tsv'), 'w') as fbiome:
        for b in sorted(obs_biome.items(), key=lambda x: x[1], reverse=True):
            fbiome.write(str(b[1]) + '\t' + b[0] + '\n')

    file_peptides.close()
    new_fasta.close()
