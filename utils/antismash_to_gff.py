#!/usr/bin/env python
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
#
import argparse
import subprocess

from Bio import SeqIO


def aggregate_clusters(geneclus_file):
    """Parse the genecluster.txt file and return a dict.
    Each entry on the dict:
    {
        'contig_id': [
            'cluster_id' ex. terpene,
            [
                'features names on embl' ex. ctg467_5
            ]
        ]
    }
    """
    res = {}
    with open(geneclus_file, 'r') as reader:
        for line in reader:
            _, contig, cluster, entries, _ = line.split('\t')
            contig_id = contig.replace(' ', '-')
            if contig_id not in res:
                res[contig_id] = []
            res[contig_id].extend(list(map(lambda f_id: (f_id, cluster),
                                  entries.split(';'))))
    return res


def build_gff(embl_file, gclusters):
    """Build the GFF from the geneclusters and the EMBL file
    """
    entries = SeqIO.parse(embl_file, 'embl')
    for entry in entries:
        query_name = entry.description.replace(' ', '-')
        gc_data = gclusters.get(query_name, None)
        if not gc_data:
            continue
        # get the data from the embl file
        for entry_feature in entry.features:
            if 'locus_tag' not in entry_feature.qualifiers:
                continue
            locus_tag = entry_feature.qualifiers['locus_tag'][0]
            # if this feature has multiples gclusters annotations
            # they will be stuffed on the last column of the
            # gff file
            cluster_type = filter(lambda x: x[0] == locus_tag, gc_data)
            annotations = ','.join(map(lambda x: x[1], cluster_type))
            if annotations:
                yield [
                    query_name,
                    'Prediction',
                    'CDS',
                    str(entry_feature.location.start),
                    str(entry_feature.location.end),
                    '.',  # Score
                    '+' if entry_feature.strand > 0 else '-',
                    '.',
                    'ID=' + query_name + ';antiSMASH=' + annotations
                ]


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Build an antiSMASH gff file for the webclient')
    parser.add_argument(
        '-e', dest='embl', help='EMBL antiSMASH results file',
        required=True)
    parser.add_argument(
        '-g', dest='geneclus', help='antiSMASH geneclusters.txt file',
        required=True)
    parser.add_argument(
        '-o', dest='out', help='Ouput GFF file name', required=True)
    args = parser.parse_args()

    with open(args.out, 'w') as out_handle:

        print('##gff-version 3', file=out_handle)

        clusters_data = aggregate_clusters(args.geneclus)

        for row in build_gff(args.embl, clusters_data):
            print('\t'.join(row), file=out_handle)

    print('Sorting...')
    grep = '(grep ^"#" {0}; grep -v ^"#" {0} | sort -k1,1 -k4,4n)'.format(args.out)
    grep += '| bgzip > {0}.gz'.format(args.out)
    print(grep)
    subprocess.call(grep, shell=True)
    print('Building index...')
    subprocess.call(['tabix', '-p', 'gff', '{}.gz'.format(args.out)])
