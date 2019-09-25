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

import re
import argparse


class EggResult:
    """
    Simple representation of a EggNOG result row.
    Current pipeline tsv columns
        - query_name
        - seed_eggNOG_ortholog
        - seed_ortholog_evalue
        - seed_ortholog_score
        - predicted_gene_name
        - GO_terms
        - KEGG_KOs
        - BiGG_reactions
        - Annotation_tax_scope
        - OGs
        - bestOG|evalue|score
        - COG cat
        - eggNOG annot
    """

    def __init__(self, line):
        columns = line.split('\t')
        self.query_name = columns[0].strip()
        # delete the faa number added on the annotation step
        self.ID = re.sub(r'_\d+$', '', self.query_name)
        self.seed_eggNOG_ortholog = columns[1]
        self.seed_ortholog_evalue = columns[2]
        self.seed_ortholog_score = columns[3]
        self.preferred_name = columns[4]
        self.GOs = columns[5]
        self.KEGG_ko = columns[6]
        self.BiGG_reactions = columns[7]
        # self.best_tax_level = columns[8] # Annotation_tax_scope but renamed for API sake
        self.OGs = columns[9]
        # self.bestOG = columns[10] # should we include this?
        self.COG = columns[11]
        self.eggNOG = columns[12]

    def get_annotations(self):
        """
        Get the annotation in an array
        """
        return ';'.join([a + '=' + v for a, v in self.__dict__.items() if v and a != 'query_name'])


def parse_fasta_header_mags(header):
    match = re.match(
        '^\>(?P<contig>.+\-\-contig:-.*)\s\#\s(?P<start>\d+)\s\#\s(?P<end>\d+)\s\#\s(?P<strand>\-1|1)\s.*$', header)
    if match:
        groups = match.groupdict()
        return groups['contig'], groups['start'], groups['end'], groups['strand']
    return None, None, None, None


def parse_fasta_header(header):
    # FIXME: add sanity check
    splitted = header.replace('>', '').split(' # ')
    if len(splitted) < 4:
        return None, None, None, None
    contig, start, end, strand = splitted[:4]
    return contig, start, end, strand


def build_gff(egg, faa):
    """
    The faa file will have each predirect CDS and
    on the head it has the positions on the fasta file.
    We need the position of the features to build the GFF.
    EggNOG annotations are squeezed at the end of the GFF.
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
                     information about each feature. Some of these tags are predefined,
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
    with open(egg, 'r') as egg_file:
        eggNogAnnotations = {}
        for line in egg_file:
            if '#' in line:
                continue
            eggRes = EggResult(line)
            if eggRes.query_name in eggNogAnnotations:
                eggNogAnnotations[eggRes.query_name].append(eggRes)
            else:
                eggNogAnnotations[eggRes.query_name] = [eggRes]

    records = []
    with open(faa, 'r') as faa_file:
        for line in faa_file:
            if not '>' in line:
                continue

            # each fasta is suffixed on the annotated faa if a prefix _INT (_1 .. _n)
            contig_name, start, end, strand = parse_fasta_header(line)
            if None in (contig_name, start, end, strand):
                continue

            clean_name = re.sub(r'_\d+$', '', contig_name)

            for annotation in eggNogAnnotations.get(contig_name, []):
                eggAnn = annotation.get_annotations()
                if eggAnn:
                    row = [
                        clean_name,
                        'Prediction',
                        'CDS',
                        start,
                        end,
                        annotation.seed_ortholog_score,
                        '+' if strand == '1' else '-',
                        '.',
                        eggAnn
                    ]
                    records.append(row)

    return records


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Build an assembly GFF file')
    parser.add_argument(
        '-e', dest='egg', help='EggNOG tsv results', required=True)
    parser.add_argument(
        '-f', dest='faa', help='FASTA with the CDS annotated (faa)', required=True)
    parser.add_argument(
        '-o', dest='out', help='Ouput GFF file name', required=True)
    args = parser.parse_args()

    with open(args.out, 'w') as out_handle:
        print('##gff-version 3', file=out_handle)
        for row in build_gff(args.egg, args.faa):
            print('\t'.join(row), file=out_handle, end='')