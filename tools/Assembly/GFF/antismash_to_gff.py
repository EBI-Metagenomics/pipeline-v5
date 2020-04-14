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
from urllib import parse
import json
import re

from Bio import SeqIO

import logging

logger = logging.getLogger(__name__)


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
            split = line.split('\t')            
            _, contig, cluster, entries, *_ = split
            contig_id = contig.replace(' ', '-')
            if contig_id not in res:
                res[contig_id] = []
            res[contig_id].extend(list(map(lambda f_id: (f_id, cluster),
                                  entries.split(';'))))
    return res

def antismash_load_types(json_file):
    """Load the gene types from the json
    The structure of the json is:
    {
        "cluster-74": {
            "end": 12552, 
            "idx": 74, 
            "orfs": [
                {
                    "locus_tag": "ctg562_1", 
                    "end": 282, 
                    "description": "<span ....", 
                    "start": 1, 
                    "type": "other", 
                    "strand": 1
                },...
            ]
        }, {...
        }
    }.
    Note: this json file is build from the geneclusters.js file of
    the html output of antiSMASH.
    To build the json file:
    echo ";var fs = require('fs'); fs.writeFileSync('./geneclusters.json', JSON.stringify(geneclusters));" >> geneclusters.js
    node geneclusters.js # this will generate the geneclusters.json file
    """
    feature_types = {}
    with open(json_file) as f:
        clusters = json.load(f)
        for ckey in clusters.keys():
            cluster_data = clusters[ckey]
            for orf in cluster_data.get('orfs', []):
                if 'locus_tag' in orf: 
                    feature_types[orf.get('locus_tag')] = orf.get('type', 'other')
    return feature_types

def _get_value(entry_quals, key, cb=lambda x: x):
    """Get the value from the entry and apply the callback
    """
    return list(map(lambda v: cb(v), entry_quals.get(key, [])))

def _clean_as_notes(value):
    """Remove comments that point to antiSMASH HTML images and URLEncode
    """
    if '.png' in value:
        return ''
    else:
        return parse.quote(value)

def _mags_name_clean(query_name):
    """Clean the MAGs genome name.
    MAGs .embl query_name is:
    
    GUT_GENOME096033_1-NZ_JH815228.1-Fusobacterium-ulcerans-ATCC-49185-genomic

    That name is not proper for the .gff file so it is cleaned in order to return:
    GUT_GENOME096033_1
    """
    return re.sub(r'[-|\s].+', '', query_name)

def build_attributes(entry_quals, gc_data, as_types):
    """Convert the CDS features to gff attributes field for an CDS entry
    """
    locus_tag = entry_quals.get('locus_tag')[0]
    attributes = []
    attributes.append(['as_notes', _get_value(entry_quals, 'note', _clean_as_notes)])
    attributes.append(['as_gene_functions', _get_value(entry_quals, 'gene_functions')])
    # gene kinds | types possible values:
    # - biosynthetic (core)
    # - biosynthetic-additional
    # - other
    # - regulatory
    # - transport
    if locus_tag in as_types:
        types = [as_types[locus_tag]]
        attributes.append(['as_type', types])
        # stuff the gene cluster data
        if not 'other' in types:
            cluster_type = filter(lambda x: x[0] == locus_tag, gc_data)        
            attributes.append(['as_gene_clusters', list(map(lambda x: x[1], cluster_type))])
    else:
        attributes.append(['as_type', ['other']])
    attributes.append(['as_gene_kind', _get_value(entry_quals, 'gene_kind')])
    attributes.append(['product', _get_value(entry_quals, 'product')])
    return ';'.join([name + '=' + ','.join(values) for name,values in attributes if len(values)])

def build_gff(embl_file, gclusters, as_types, mag=False):
    """Build the GFF from the geneclusters and the EMBL file
    """
    entries = SeqIO.parse(embl_file, 'embl')
    for entry in entries:
        query_name = entry.description
        if mag:
            query_name = _mags_name_clean(query_name)
        query_name = query_name.replace(' ', '-')
        # filter the embl file by the contigs that have a 
        # gene cluster entry in the geneclusters.txt file
        gc_data = gclusters.get(query_name, None)
        if not gc_data:
            continue
        # get the data from the embl file
        for entry_feature in entry.features:
            if entry_feature.type != 'CDS':
                continue

            quals = entry_feature.qualifiers
            if 'locus_tag' not in quals:
                continue

            attributes = build_attributes(quals, gc_data, as_types)
            if attributes:
                yield [
                    query_name,
                    'antiSMASH',
                    'CDS',
                    str(entry_feature.location.start + 1), # correct offset gff are +1
                    str(entry_feature.location.end + 1),
                    '.',  # Score
                    '+' if entry_feature.strand > 0 else '-',
                    '.',
                    'ID=' + query_name + ';' + attributes
                ]
            else:
                logger.warning(entry.id + ' has no attributes')


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
        '-j', dest='gc_json', help='antiSMASH geneclusters.json file',
        required=True)
    parser.add_argument(
        '--mag', help='MAGs use a specific naming convention on the EMBL file.' +
                       'This flag will process the DESC field on the EMBL to correct that',
        action='store_true')
    parser.add_argument(
        '--no-tabix', help='Disable the compressed gff build process.',
        action='store_true'
    )
    parser.add_argument(
        '-o', dest='out', help='Ouput GFF file name', required=True)
    args = parser.parse_args()

    with open(args.out, 'w') as out_handle:

        print('##gff-version 3', file=out_handle)

        clusters_data = aggregate_clusters(args.geneclus)
        as_types = antismash_load_types(args.gc_json)        

        for row in build_gff(args.embl, clusters_data, as_types, mag=args.mag):
            print('\t'.join(row), file=out_handle)

    if not args.no_tabix:
        print('Sorting...')
        grep = '(grep ^"#" {0}; grep -v ^"#" {0} | sort -k1,1 -k4,4n)'.format(args.out)
        grep += '| bgzip > {0}.bgz'.format(args.out)
        print(grep)
        subprocess.call(grep, shell=True)
        print('Building index...')
        subprocess.call(['tabix', '-p', 'gff', '{}.bgz'.format(args.out)])
