#!/usr/bin/env python3

"""
Script does assign of MGYPs to protein sequences in input fasta-file.

Input:
 - fasta-file (proteins)
 - run accession
 - study accession
 - config file with paths to db-files
 - number of db release to use
 - json (contig_name - mgyc) file
Output:
 - accession.mgyp.fasta (input fasta with MGYPs)
 - long-proteins-number.txt (number of long proteins in given fasta-file)
 - peptides.txt (information about peptides)
 - all-biomes.txt ???
 - mgy_biome_counts_DB.tsv ???
"""

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
import gzip

TYPE = 'mgyp'

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--fasta', dest='fasta', required=True, help='Fasta file with proteins', nargs='+')
    parser.add_argument("-a", "--accession", help="run accession", dest="accession", required=False)
    parser.add_argument("-s", "--study", help="study accession", dest="study", required=True)
    parser.add_argument('-c', '--config', dest='config', required=True, help='path to mapping dir')
    parser.add_argument("-r", "--release", help="release name where to write new accessions", dest="release",
                        required=True)
    parser.add_argument("--private", help="set this option if run is from private request", dest="private",
                        required=False, action='store_true')
    parser.add_argument("-j", "--json", help="json map-file", dest="json", required=False, nargs='+')
    parser.add_argument("--path-fasta", help="generate mgyp.fasta in assembly_peptides folder", required=False,
                        action='store_true')
    parser.add_argument('-v', '--verbose', action='store_true')
    return parser


def read_config(config, release):
    with open(config, 'r') as fc:
        config = json.loads(fc.read())
        mapping_dir = config['mapping']
        max_pep_length = config['max_pep_length']
        peptides = config['peptides']
        if not os.path.exists(peptides): os.mkdir(peptides)
    # check mapping dir for existence
    cur_mapping_dir = os.path.join(mapping_dir, TYPE, release)
    logging.info('Current mapping directory: ' + str(cur_mapping_dir))
    if not os.path.exists(cur_mapping_dir):
        logging.error("Mapping directory doesn't exist")
        exit(1)
    return max_pep_length, peptides, cur_mapping_dir


def create_peptides_file(peptides, accessions, study, path_fasta):
    peptides_tables, mgyp_fastas = {}, {}
    for accession in accessions:
        # peptides files
        folder = os.path.join(peptides, study, accession)
        os.makedirs(folder, exist_ok=True)
        peptides_file = os.path.join(folder, 'peptides.txt')
        peptides_tables[accession] = open(peptides_file, 'w')
        # new fasta files
        if path_fasta:
            mgyp_fasta = os.path.join(folder, accession + '_FASTA.mgyp.fasta')
        else:
            mgyp_fasta = accession + '_FASTA.mgyp.fasta'
        mgyp_fastas[accession] = open(mgyp_fasta, 'w')
        logging.info('New FASTA file: ' + mgyp_fasta)
    return peptides_tables, mgyp_fastas


def create_digest(seq):
    #h = hashlib.new('sha256')
    #digest = h.update(seq.encode('utf-8')).hexdigest()
    digest = hashlib.sha256(str(seq).encode('utf-8')).hexdigest()
    return digest


def read_map_file(file, mode='json'):
    extension = {'pickle': '.pkl', 'json': '.json'}
    start = time.time()
    map = {}
    if not os.path.exists(file):
        return map
    if os.path.exists(file+extension[mode]):
        if mode == 'pickle':
            with open(file+extension[mode], 'rb') as read_file:
                map = cPickle.load(read_file)
                logging.debug('pickle')
        elif mode == 'json':
            with open(file+extension[mode], 'r') as read_file:
                map = json.load(read_file)
                logging.debug('json')
        else:
            with open(file) as fh:
                logging.debug('table')
                for line in fh:
                    seq, partial, *_ = line.rstrip().split(' ')
                    acc = _[0]
                    public_sign = _[1] if len(_) > 1 else 0
                    if not seq in map:
                        map[seq] = {}
                    map[seq][partial] = [acc, public_sign]
    else:
        with open(file) as fh:
            logging.debug('table')
            for line in fh:
                seq, partial, *_ = line.rstrip().split(' ')
                acc = _[0]
                public_sign = _[1] if len(_) > 1 else 0
                if not seq in map:
                    map[seq] = {}
                map[seq][partial] = [acc, public_sign]
    end = time.time()
    return map, end-start


def save_map_file(map, cur_twochar, mode='json'):
    extension = {'pickle': '.pkl', 'json': '.json'}
    start = time.time()
    gc.disable()
    if mode == 'pickle':
        with open(cur_twochar + extension[mode], 'wb') as pickle_file:
            cPickle.dump(map, pickle_file)
        pickle_file.close()
    else:
        with open(cur_twochar + extension[mode], 'w') as json_file:
            json.dump(map, json_file)
        json_file.close()
    gc.enable()
    end = time.time()
    logging.info('Saving took ' + str(end - start) + 's')


def map_accessions(seq, partial, map, next_acc, public):
    if seq in map and partial in map[seq]:
        logging.debug('----------- found seq and partial in map-file')
        acc = map[seq][partial][0]
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
    return next_acc, acc


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
    logging.debug('... receiving lock ...')
    with lockutils.lock('max_acc.lock', lock_path=cur_mapping_dir, external=True):
        try:
            logging.debug('Locking max_acc file ...')
            # Read the last given accession number
            fd = open(file_next_accession, 'r+')
            max = int(fd.read()) + 1
            logging.info('Start with accession number ' + str(max))
            next_acc = max + number_new_records
            fd.seek(0)
            fd.truncate()
            # write next accession
            fd.write(str(next_acc))
            logging.info('Finish with accession number ' + str(next_acc))
            logging.debug('... Return max_acc file')
        except IOError:
            os._exit(3)
        finally:
            fd.close()
    return int(max)


def open_fasta(filename):
    if filename.endswith('.gz'):
        return gzip.open(filename, 'rt')
    else:
        return open(filename, 'r')


def read_fasta_and_json(fastas, jsons, max_pep_length, peptides_subfolder):
    """
    If Json given - read MGYC from json; else MGYC = protein record.id
    Script creates dict by twochar for proteins and their mgycs
    :param fastas:
    :param jsons:
    :return:
           dict_hash_records: {00: [(record1, MGYC1, run_accession), (record2, MGYC2, run_accession)], 01:...}
           used_twochar: list of used twochar hashes
    """
    dict_hash_records = {}
    long_peptides = 0
    run_accessions = {}
    # read fasta file, create digests
    for number in range(len(fastas)):
        logging.info('Reading ' + str(number+1))
        if jsons:
            json_file = open(jsons[number], 'r')
            map_fasta_file = json.load(json_file)
        fasta_file = open_fasta(fastas[number])
        run_accession = os.path.basename(fastas[number]).split('_')[0]
        run_accessions.setdefault(run_accession, 0)
        for record in SeqIO.parse(fasta_file, "fasta"):
            if len(record.seq) > max_pep_length:
                long_peptides += 1
            hash_seq = create_digest(str(record.seq))
            twochar = hash_seq[:2]
            if jsons:
                contig_name = record.id.split(' ')[0].split('_')[0]
                mgyc = map_fasta_file[contig_name]
            else:
                mgyc = record.id
            dict_hash_records.setdefault(twochar, []).append(tuple([record, mgyc, run_accession]))
        fasta_file.close()
        json_file.close()

    used_twochar = list(dict_hash_records.keys())
    logging.info('Used twochar hashes: ' + str(used_twochar))

    # write long peptides
    os.makedirs(peptides_subfolder, exist_ok=True)
    long_peptides_file = os.path.join(peptides_subfolder, 'long-proteins-number.txt')
    long_file = open(long_peptides_file, 'w+')
    value = long_file.read()
    given_value = 0 if value == '' else int(value)
    long_file.seek(0)
    long_file.truncate()
    logging.info('Write number of long peptides: ' + str(long_peptides_file) + ' ' + str(given_value) + '+'
                 + str(long_peptides))
    long_file.write(str(long_peptides + given_value))
    long_file.close()
    return dict_hash_records, used_twochar, list(run_accessions.keys())


if __name__ == "__main__":

    args = get_args().parse_args()
    input_jsons = args.json
    input_fastas = args.fasta
    public_value = 1 if args.private else 0
    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO)
    if args.json:
        if len(args.json) == 1:
            if len(args.json[0].split(" ")) > 1:
                input_jsons = args.json[0].split(" ")
                input_fastas = args.fasta[0].split(" ")
        if len(input_jsons) != len(input_fastas):
            logging.error("#json != #fasta")
            exit(4)
        else:
            logging.info('Given ' + str(len(input_fastas)) + ' jsons and fastas')
    # read config
    max_pep_length, peptides, cur_mapping_dir = read_config(args.config, args.release)

    # ---- read fastas ----
    dict_hash_records, used_twochar, run_accessions = read_fasta_and_json(fastas=input_fastas, jsons=input_jsons,
                                                          max_pep_length=max_pep_length,
                                                          peptides_subfolder=os.path.join(peptides, args.study))
    # create peptides file
    peptides_tables, mgyp_fastas = create_peptides_file(peptides, run_accessions, args.study, args.path_fasta)

    # prepare dict with names
    files_hash = {}
    for twochar in used_twochar:
        files_hash[twochar] = os.path.join(cur_mapping_dir, twochar)

    test = dict_hash_records
    #test['11'] = dict_hash_records['11']

    for num_twochar, twochar in zip(range(len(test)), test):
        cur_twochar = files_hash[twochar]
        with lockutils.lock(twochar+'.lock', lock_path=os.path.dirname(cur_twochar), external=True):
            # read existing map-file
            mapping_dir_release = os.path.join(cur_mapping_dir, twochar)
            logging.debug('---> Reading map file from ' + str(mapping_dir_release))
            map, reading_time = read_map_file(mapping_dir_release, mode='json')
            logging.info('Process: ' + twochar + '(' + str(num_twochar) + '/' + str(len(dict_hash_records)) + '), peptides:'
                         + str(len(dict_hash_records[twochar])) + ', size of map: ' + str(len(map)) + ', reading time: '
                         + str(reading_time) + 's')

            # find new records for map file
            new_records = []
            for record_tuple, num in zip(dict_hash_records[twochar], range(len(dict_hash_records[twochar]))):
                record = record_tuple[0]
                partial, start_coordinate, stop_coordinate, strand, caller = parsing_header(record.description)
                if num % 100 == 0: logging.debug('Processed ' + str(num))
                if not (record.seq in map and partial in map[record.seq]):
                    new_records.append(record)

            # update accessions-file
            file_next_accession = os.path.join(cur_mapping_dir, 'max_acc')
            cur_max_accession = update_max_accession(len(new_records), file_next_accession)
            try:
                file_desc_twochar = open(cur_twochar, 'r+')
                # adding all proteins
                logging.debug('-----> processing map-file')
                for record_tuple, num in zip(dict_hash_records[twochar], range(len(dict_hash_records[twochar]))):
                    record = record_tuple[0]
                    mgyc = record_tuple[1]
                    accession = record_tuple[2]
                    file_peptides = peptides_tables[accession]
                    new_fasta = mgyp_fastas[accession]
                    partial, start_coordinate, stop_coordinate, strand, caller = parsing_header(record.description)
                    logging.info(record.id)
                    cur_max_accession, mgy_accession = map_accessions(map=map, next_acc=cur_max_accession,
                                                                                    seq=str(record.seq), partial=partial,
                                                                                    public=public_value)

                    # write table of protein data
                    file_peptides.write(' '.join([mgy_accession, mgyc, start_coordinate, stop_coordinate, strand,
                                                  partial, caller]) + '\n')
                    record.id = mgy_accession
                    record.description = mgy_accession
                    # write fasta file with new accessions
                    SeqIO.write(record, new_fasta, "fasta")
                    if num % 100 == 0: logging.info('Processed ' + str(num))
                save_map_file(map, cur_twochar, mode='json')
            except IOError:
                os._exit(2)
            finally:
                file_desc_twochar.close()
            logging.debug('-----> Check final accession: ' + str(cur_max_accession))

    for accession in run_accessions:
        peptides_tables[accession].close()
        mgyp_fastas[accession].close()
    logging.info('END')