#!/usr/bin/env /home/maxim/.virtualenvs/mgpipeline/bin/python
# -*- coding: utf-8 -*-

# Copyright 2019 EMBL - European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
    Quality control filtering step using the BioPython package.
"""
import argparse
import logging
import os
import sys

from Bio import SeqIO
from Bio.SeqIO.FastaIO import FastaWriter
from Bio.SeqRecord import SeqRecord


def parse_args(argv):
    parser = argparse.ArgumentParser(
        description='Quality control filtering step built into the Mgnify pipeline.')
    parser.add_argument('seq_file', help='Sequence file path', type=str)
    parser.add_argument('output_file_name', help='FASTA formatted output file name', type=str)
    parser.add_argument('--min_length', help='Minimum read length', type=int, default=100)
    return parser.parse_args(argv)


def get_proportion(sequence, character):
    count = sequence.upper().count(character.upper())
    sequence_length = len(sequence)
    return count / float(sequence_length)


def filter_sequences(seq_file, file_format, min_read_length):
    """
        Discards sequences that are 99 bp or less, or > 10% N.

        The Python yield keyword explained:
        https://pythontips.com/2013/09/29/the-python-yield-keyword-explained/
    :param seq_file:
    :param file_format:
    :param min_read_length:
    :return:
    """
    total_sequence_counter = 0
    rejected_length_counter = 0
    rejected_n_counter = 0

    for record in SeqIO.parse(seq_file, file_format):
        total_sequence_counter += 1

        trimmed_seq = record.seq.upper().strip('N')
        if len(trimmed_seq) >= min_read_length:
            if get_proportion(trimmed_seq, "N") < 0.1:
                yield SeqRecord(trimmed_seq, id=record.id, description=record.description)
            else:
                rejected_n_counter += 1
        else:
            rejected_length_counter += 1
    length_filtered = total_sequence_counter - rejected_length_counter
    nbase_filtered = length_filtered - rejected_length_counter
    sys.stdout.write("after_trimmed:{},after_length:{},after_nbases:{}".format(total_sequence_counter, length_filtered,
                                                                               nbase_filtered))


def parse_file_format(file_name):
    """
        Please note: This MUST contain all sequence formats we expect as key and the necessary BioPython format option
        as value.
        NB the BioPython format option is not always identical to the sequence format name.


    :param file_name:
    :return:
    """

    extension = os.path.splitext(file_name)[1][1:].strip().lower()

    dictFormat = {'sff': 'sff-trim', 'fasta': 'fasta', 'fastq': 'fastq', 'fq': 'fastq'}
    file_format = dictFormat.get(extension)
    if not file_format:
        logging.error('Unable to determine file format {0} for parsing'.format(extension))
        sys.exit(2)
    return file_format


def write_fasta_output(output_file_name, filtered_seqs):
    handle = open(output_file_name, "w")
    writer = FastaWriter(handle)
    writer.write_file(filtered_seqs)
    handle.close()


def main(argv=sys.argv[1:]):
    args = parse_args(argv)

    file_format = parse_file_format(args.seq_file)

    filtered_seqs = filter_sequences(args.seq_file, file_format, args.min_length)
    write_fasta_output(args.output_file_name, filtered_seqs)


if __name__ == '__main__':
    main()
