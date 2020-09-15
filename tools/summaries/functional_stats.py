#!/usr/bin/env python3
from __future__ import print_function
import yaml
import os
import argparse
import sys
from Bio import SeqIO
import re


'''script to generate stats for each funtional analysis and orf stats. Each function pulls out total number of matches, number of predicted coding sequences with match
and number of contigs with match. ORF stats gives number of CDS, contigs with CDS and Reads with RNA. Outputs in TSV format.
Entry map is generated for InterProScan as input to write IPR summary'''

def orf_stats(cds_file, cmsearch_deoverlap, outdir, reads_contigs):
    numberOrfs = 0
    readsWithOrf = set()
    readsWithRNA = set()
    for record in SeqIO.parse(cds_file, "fasta"):
        ID = (record.id.split("_"))[0]
        readsWithOrf.add(ID)
        numberOrfs += 1
    numberReadsWithOrf = len(readsWithOrf)
    for hit in open(cmsearch_deoverlap, "r"):
        RNAaccession = re.search("(\S+)\s+-", hit.strip())[1]
        readsWithRNA.add(RNAaccession)
    numberReadswithRNA = len(readsWithRNA)
    with open(os.path.join(outdir, "orf.stats"), "w") as file_out:
        file_out.write("\n".join(["Predicted CDS\t{numberOrfs}",
                                  "{reads_contigs} with predicted CDS\t{numberReadsWithOrf}",
                                  "{reads_contigs} with predicted rRNA\t{numberReadswithRNA}"]))


'''
def define_tool(input_file):
    filename = os.path.basename(input_file)
    print(filename)
    if len(filename.split('hmm')) > 1 or len(filename.split('hmmscan')) > 1:
        return 'KO'
    elif len(filename.split('interpro')) > 1 or len(filename.split('.I5.')) > 1:
        return 'InterProScan'
    elif len(filename.split('pfam')) > 1:
        return 'pfam'
    else:
        print('There is no matches with input name')
'''


def get_ko_desc(ko_file):
    ko_dict = {}
    with open(ko_file, 'r') as desc:
        for line in desc:
            split_line = line.strip('\n').split('\t')
            ko_dict[split_line[0]] = split_line[1]
    return ko_dict


def stats(input_file, cds_column_number, protein_column_number, hash, outdir, ko_file, reads_contigs):

    match_count, CDS_with_match_number, reads_with_match_count, go_match_count, go_CDS_match, go_reads_match \
        = [0 for _ in range(6)]

    cds, reads, go_cds, go_reads = [set() for _ in range(4)]
    entry2protein, entry2name = [{} for _ in range(2)]
    ko_dict = get_ko_desc(ko_file)

    print(hash + ' :cds_column_number: ' + str(cds_column_number) + ', protein_column_number: ' + str(protein_column_number))

    for line in open(input_file, "r"):
        splitLine = line.strip().split("\t")
        cdsAccessions = splitLine[cds_column_number].split("|")
        for cdsAccession in cdsAccessions:
            cds.add(cdsAccession)
            readAccession = (cdsAccession.split("_"))[0]
            reads.add(readAccession)

            if hash == 'InterProScan':
                if len(splitLine) >= 13 and splitLine[11].startswith("IPR"):
                    entry = splitLine[protein_column_number]  # 11
                    entry2protein.setdefault(entry, set()).add(cdsAccession)
                    entry2name[entry] = splitLine[12]

                if len(splitLine) >= 14 and splitLine[13].startswith("GO"):
                    goterms = splitLine[13].split("|")
                    go_cds.add(cdsAccession)
                    go_reads.add(cdsAccession.split("_")[0])
                    go_match_count += len(goterms)
            else:
                entry = splitLine[protein_column_number]
                entry2protein.setdefault(entry, set()).add(cdsAccession)
                if hash == 'KO':
                    entry2name[entry] = ko_dict[entry]
                elif hash == 'pfam':
                    entry2name[entry] = splitLine[5]
                elif hash == 'antismash':
                    entry2name[entry] = splitLine[5]

            match_count += 1

    CDS_with_match_count = len(cds)
    reads_with_match_count = len(reads)
    go_CDS_match = len(go_cds)
    go_reads_match = len(go_reads)

    with open(hash + "_entry_maps.yaml", "w") as mapsFile:
        yaml.dump({"entry2protein": entry2protein,
                   "entry2name": entry2name}, mapsFile)

    with open(os.path.join(outdir, hash.lower() + ".stats"), "w") as file_out:
        file_out.write("\n".join(["Total {hash} matches\t{match_count}",
                                  "Predicted CDS with {hash} match\t{CDS_with_match_count}",
                                  "{reads_contigs} with {hash} match\t{reads_with_match_count}"]))
    if hash == 'InterProScan':
        with open(os.path.join(outdir, "go.stats"), "w") as file_out:
            file_out.write("\n".join(["Total GO matches\t{go_match_count}",
                                      "Predicted CDS with GO match\t{go_CDS_match}",
                                      "{reads_contigs} with GO match\t{go_reads_match}"]))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generates stats files for all functional analyses")
    parser.add_argument('-ko', "--ko_file", dest="ko_file", help='KO to decription mapping file', required=True)
    parser.add_argument("-i", "--interproscan", dest="interproscan", help="interproscan predicted seqs", required=True)
    parser.add_argument("-k", "--hmmscan", dest="hmmscan", help="hmmscan predicted seqs", required=True)
    parser.add_argument("-p", "--pfam", dest="pfam", help="pfam annotation predicted seqs", required=True)
    parser.add_argument("-r", "--rna", dest="cmsearch_deoverlap", help="cmsearch deoverlapped results", required=True)
    parser.add_argument("-c", "--cds", dest="cds_file", help="predicted coding sequences", required=True)
    parser.add_argument("-a", "--antismash", dest="antismash", help="antismash gene clusters", required=False)
    parser.add_argument("-t", "--type", dest="type", help="Contigs or Reads", required=False)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        final_folder = os.path.join('functional-annotation', 'stats')
        if not os.path.exists(final_folder): os.makedirs(final_folder)

        cdsAccessions_list = {'KO': 0, 'pfam': 0, 'InterProScan': 0, 'antismash': 1}
        protein_column = {'KO': 3, 'pfam': 4, 'InterProScan': 11, 'antismash': 2}


        files = [args.interproscan, args.hmmscan, args.pfam]
        hashes = ['InterProScan', 'KO', 'pfam']

        if args.antismash:
            hashes.append('antismash')
            files.append(args.antismash)

        for file_annotation, num in zip(files, range(len(files))):
            print(file_annotation)
            hash = hashes[num]
            stats(file_annotation, cdsAccessions_list[hash], protein_column[hash], hash, final_folder, args.ko_file, args.type)

        orf_stats(args.cds_file, args.cmsearch_deoverlap, final_folder, args.type)