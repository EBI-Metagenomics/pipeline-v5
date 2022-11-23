#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright 2022 EMBL - European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# pdb_registration.py
# Script to search or add proteins to ProteinDB.

import re
import json
import hashlib
import logging
import argparse
import pymysql.cursors
from Bio import SeqIO

assembly_acc_patt = re.compile("([E|S|D]RZ\d{6,})")
partial_flag_patt = re.compile("partial=(\d\d)")

def load_config(file):
    with open(file, "rt") as fh:
        config = json.load(fh)
    # quick validation
    for db in ['pdb', 'emg']:
        if db in config:
            if  'host' in config[db] and 
                'user' in config[db] and
                'port' in config[db] and
                'passw' in config[db] and
                'dbname' in config[db]:
                logging.debug(f"Config for {db} is ok")
            else:
                logging.error(f"Config file {file} is incomplete")
                raise Exception

    return config

def create_digest(input_string):
    digest = hashlib.sha256(str(input_string).encode('utf-8')).hexdigest()
    return digest

def get_connection(config_dict):
    connection = pymysql.connect(host=config_dict['host'],
                                user=config_dict['user'],
                                password=config_dict['passw'],
                                port=int(config_dict['port']),
                                database=config_dict['dbname'],
                                charset='utf8mb4',
                                cursorclass=pymysql.cursors.DictCursor)
    cursor = connection.cursor()
    return cursor, connection


def process_fasta(fasta_in, fasta_out, config):
    m = assembly_acc_patt.search(fasta_in)
    if m:
        assembly_acc = m.group(0)
    else:
        logging.error("File doesn't have assembly accession, abort")
        raise Exception
    priv_status = is_assembly_private(assembly_acc, config['emg'])

    pdb_cursor, pdb_conn = get_connection(config['pdb'])
    with open(fasta_out, "wt") as out_fh:
        with open(fasta_in) as in_fh:
            for record in SeqIO.parse(in_fh, "fasta"):
                flag_match = partial_flag_patt.search(record.description)
                if flag_match:
                    flag = flag_match.group(0)
                else:
                    flag = '11'

                digest = create_digest(flag + record.seq)
                mgyp_id = get_or_insert_protein(pdb_cursor, pdb_conn, digest, record.seq, priv_status)
                mgyp = "MGYP" + str(mgyp_id).zfill(12)
                record.id = mgyp
                SeqIO.write(record, out_fh, "fasta")

    pdb_cursor.close()
    pdb_conn.close()


def is_assembly_private(accession, config):
    logging.debug(f"Searching if assembly {accession} is private in EMG backlog")
    emg_cursor, emg_conn = get_connection(config)
    query = f"SELECT public FROM Assembly WHERE primary_accession = '{accession}';"
    emg_cursor.execute(query)
    res = emg_cursor.fetchone()
    emg_cursor.close()
    emg_connection.close()

    if res:
        if res['public'] == '0':
            return 1
        else:
            return 0
    else:
        logging.error(f"Assembly {accession} doesn't have a private/public status in EMG backlog. abort")
        raise Exception

def get_or_insert_protein(cursor, conn, dig, seq, priv):
    query = "SELECT id FROM protein WHERE digest = '{}';".format(dig)
    cursor.execute(query)
    res = cursor.fetchone()
    if res:
        return res['id']
    else:
        insert = "INSERT INTO protein (digest, sequence, private) VALUES ('{}', '{}', {});".format(dig, seq, pub)
        try:
            cursor.execute(insert)
            conn.commit()
        except pymysql.Error as err:
            logging.error(err)

    # Validate insertion
    cursor.execute(query)
    res = cursor.fetchone()
    if res:
        return res['id']
    else:
        logging.error("Protein insertion for ({}, {}, {}) has failed".format(dig, seq, pub))
        raise Exception

def main():
    parser = argparse.ArgumentParser(description="Script to search or add proteins to ProteinDB.")
    parser.add_argument("-f", "--fasta",
                        help="Path to protein file (Fasta)",
                        type=str,
                        required=True)
    parser.add_argument("-c", "--config",
                        help="Path to db connection secrets",
                        type=str,
                        required=True)
    parser.add_argument("-v", "--verbose",
                        help="Use verbose mode",
                        action="store_true")
    args = parser.parse_args()
    
    if args.fasta:
        fasta_file = args.fasta
    if args.config:
        config_file = args.config
    out_file = fasta_file.replace(".faa", ".pdb.faa")    

    if args.verbose:
        logging.basicConfig(format='%(asctime)s | %(levelname)s | %(message)s', level=logging.DEBUG)

    logging.debug("Fasta file: {}".format(fasta_file))
    logging.debug("Config file: {}".format(config_file))
    logging.debug("Output file: {}".format(out_file))

    config = load_config(config_file)
    process_fasta(fasta_file, out_file, config)

    logging.debug("All done")


if __name__ == "__main__":
    main()
