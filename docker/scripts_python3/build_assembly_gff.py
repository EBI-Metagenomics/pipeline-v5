#!/usr/bin/env python3

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
import re
import subprocess
import sys
from urllib import parse


class Annotation:

    @classmethod
    def merge(cls, annotations):
        """Merge the annotations.
        For example if 2 files have the KEGG annotations the output should be:
        - KEGG=KO001,KO002
        and not KEGG=KO001;KEGG=KO002
        """
        result = {}
        for ann in annotations:
            for k, v in ann:
                if k in result:
                    result[k].update(v)
                else:
                    result[k] = set(v)
        return result

    @classmethod
    def clean_seq_name(cls, name):
        return re.sub(r'_\d+$', '', name)

    def _split_line(self, line):
        return line.replace('\n', ' ').replace('\r', '').split('\t')

    def _get_value(self, value, split=True):
        if split:
            return list(filter(None, value.strip().split(',')))
        else:
            return [value.strip()] if value else []

    def get(self):
        """
        Get the annotation in an array with [Key,Value] structure
        """
        return [[a, v] for a, v in sorted(self.__dict__.items()) if a != 'query_name' and len(v)]


class EggResult(Annotation):
    """EggNOG tsv result row.
    """
    def __init__(self, line):
        """Lines parsed according to the documentation
        https://github.com/eggnogdb/eggnog-mapper/wiki/eggNOG-mapper-v2#v200
        """
        columns = self._split_line(line)
        self.query_name = columns[0].strip()
        self.eggnog_ortholog = self._get_value(columns[1], split=False)
        self.eggnog_score = self._get_value(columns[2], split=False)
        self.eggnog_evalue = self._get_value(columns[3], split=False)
        self.eggnog_tax = self._get_value(columns[5], split=False)

        self.go = self._get_value(columns[6])
        self.ecnumber = self._get_value(columns[7])
        self.kegg = self._get_value(columns[8])
        self.brite = self._get_value(columns[13])
        self.bigg_reaction = self._get_value(columns[16])
        self.ogs = self._get_value(columns[19])
        self.cog = self._get_value(columns[20])
        self.eggnog = [parse.quote(columns[21])] if columns[21] else []


class InterProResult(Annotation):
    """InterPro scan result row.
    """
    def __init__(self, line):
        columns = self._split_line(line)
        self.query_name = columns[0].strip()
        pfam = columns[4]
        if re.match('PF\d+', pfam): # noqa
            self.pfam = self._get_value(pfam)
        if len(columns) > 11:
            self.interpro = self._get_value(columns[11])


def parse_fasta_header_mags(header):
    match = re.match(
        '^\>(?P<contig>.+\-\-contig:-.*)\s\#\s(?P<start>\d+)\s\#\s(?P<end>\d+)\s\#\s(?P<strand>\-1|1)\s.*$', header) # noqa
    if match:
        groups = match.groupdict()
        return groups['contig'], groups['start'], groups['end'], groups['strand']
    return None, None, None, None


def parse_fasta_header(header):
    # FIXME: add sanity check
    # FIXME: what should we do with cases like :
    #        ERZ477576.1085103-NODE-1085103-length-126-cov-0.633803_1_126_+ 
    splitted = header.replace('>', '').split(' # ')
    if len(splitted) < 4:
        return None, None, None, None
    return splitted[:4]


def load_annotation(file, klass, annotations):
    """Load the annotations of a TSV by `query_name` (contig name at the moment)
    """
    with open(file, 'rt') as ann_file:
        for line in ann_file:
            if '#' in line:
                continue
            parsed_line = klass(line)
            if parsed_line.query_name in annotations:
                annotations[parsed_line.query_name].append(parsed_line)
            else:
                annotations[parsed_line.query_name] = [parsed_line]


def build_gff(annotations, faa):
    """
    The faa file will have each predirect CDS and
    on the head it has the positions on the fasta file.
    We need the position of the features to build the GFF.

    GFF specification, tab separated file.

    ##gff-version 3 => first line

    Each row =>
        seqid      - name of the chromosome or scaffold
        source     - name of the program that generated this feature, or the data source (database or project name)
        type       - type of feature. Must be a term or accession from the SOFA sequence ontology
        start      - start position of the feature, with sequence numbering starting at 1.
        end        - end position of the feature, with sequence numbering starting at 1.
        score      - a floating point value.
        strand     - defined as + (forward) or - (reverse).
        phase      - One of '0', '1' or '2'. '0' indicates that the first base of the feature is the first base of a codon,
                     '1' that the second base is the first base of a codon, and so on..
        attributes - a semicolon-separated list of tag-value pairs, providing additional
                     information about each feature. Some of these tags are predefined.
                     e.g. ID, Name, Alias, Parent - see the GFF documentation for more details.
    Example:
    ##gff-version 3
    ctg123 . mRNA            1300  9000  .  +  .  ID=mrna0001;Name=sonichedgehog
    ctg123 . exon            1300  1500  .  +  .  ID=exon00001;Parent=mrna0001
    ctg123 . exon            1050  1500  .  +  .  ID=exon00002;Parent=mrna0001
    ctg123 . exon            3000  3902  .  +  .  ID=exon00003;Parent=mrna0001
    ctg123 . exon            5000  5500  .  +  .  ID=exon00004;Parent=mrna0001
    ctg123 . exon            7000  9000  .  +  .  ID=exon00005;Parent=mrna0001
    """
    with open(faa, 'rt') as faa_file:
        for line in faa_file:
            if '>' not in line:
                continue

            # each fasta is suffixed on the annotated faa if a prefix _INT (_1 .. _n)
            contig_name, start, end, strand = parse_fasta_header(line)
            if None in (contig_name, start, end, strand):
                print(line, end='', file=sys.stderr)
                continue

            clean_name = Annotation.clean_seq_name(contig_name)

            row_annotations = Annotation.merge([ann.get() for ann in annotations.get(contig_name, [])])

            ann_string = ';'.join(['{}={}'.format(k, ','.join(v).strip()) for k, v in row_annotations.items()])

            eggNOGScore = ''.join(row_annotations.get('eggNOG_score', []))

            if len(ann_string):
                yield [
                    clean_name,
                    'eggNOG-v2',
                    'CDS',
                    start,
                    end,
                    eggNOGScore or '.',
                    '+' if strand == '1' else '-',
                    '.',
                    'ID=' + clean_name + ';' + ann_string
                ]


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Build an assembly GFF file (sorted and indexed using samtools and tabix)')
    parser.add_argument(
        '-e', dest='egg', help='EggNOG tsv results. eggNOG version 2 required.', required=False)
    parser.add_argument(
        '-i', dest='interpro', help='InterProScan tsv results', required=False)
    # FIXME: Are we going to use this?
    # parser.add_argument(
        # '-a', dest='antismash', help='antiSMASH tsv results (geneclusters.txt)', required=False)
    # FIXME: Are we going to use this?
    # parser.add_argument(
    #     '-k', dest='keggmodule', help='KEGG Modules per contig annotation', required=False)
    parser.add_argument(
        '-f', dest='faa', help='FASTA with the CDS annotated (faa)', required=True)
    parser.add_argument(
        '-o', dest='out', help='Ouput GFF file name', required=True)
    args = parser.parse_args()

    with open(args.out, 'w', buffering=1) as out_handle:

        print('##gff-version 3', file=out_handle)

        annotations = {}
        load_annotation(args.egg, EggResult, annotations)
        load_annotation(args.interpro, InterProResult, annotations)

        for row in build_gff(annotations, args.faa):
            print('\t'.join(row), file=out_handle)

    print('Sorting...')
    subprocess.call('(grep ^"#" {0}; grep -v ^"#" {0} | sort -k1,1 -k4,4n)'.format(args.out) +
                    ' | bgzip > {0}.gz'.format(args.out), shell=True)
    print('Building the index...')
    subprocess.call(['tabix', '-p', 'gff', '{}.gz'.format(args.out)])
    print('Bye')
