#!/usr/bin/env python3

import os
import re
import argparse
import sys
import glob
import pandas as pd
from Bio import SeqIO


def VF_reading(filename):
    VF_result_df = pd.read_csv(filename, sep="\t")

    # VF_high_ids
    VF_high_ids = list(VF_result_df[(VF_result_df["pvalue"] < 0.05) & (VF_result_df["score"] >= 0.90)]["name"].values)
    if len(VF_high_ids) < 1:
        print("No contigs with p < 0.05 and score >= 0.90 were reported by VirFinder")
    else:
        print(str(len(VF_high_ids)) + ' found VF high ids')

    # VF_low_ids
    VF_low_ids = list(
        VF_result_df[(VF_result_df["pvalue"] < 0.05) & (VF_result_df["score"] >= 0.70) & (VF_result_df["score"] < 0.9)][
            "name"].values)
    if len(VF_low_ids) < 1:
        print("No contigs with p < 0.05 and 0.70 <= score < 0.90 were reported by VirFinder")
    else:
        print(str(len(VF_low_ids)) + ' found VF low ids')

    return set(VF_high_ids), set(VF_low_ids)


def VS_reading(foldername):
    VirSorted_defined, VirSorted_prophages = [{}, {}]
    VirSorter_123 = [x for x in glob.glob(os.path.join(foldername, "*.fasta")) if
                            re.search(r"cat-[123]\.fasta$", x)]
    VirSorter_prophages = [x for x in glob.glob(os.path.join(foldername, "*.fasta")) if
                           re.search(r"cat-[45]\.fasta$", x)]
    print('VirSorter not prophages ' + str(len(VirSorter_123)) + ' files')
    print('VirSorter_prophages ' + str(len(VirSorter_prophages)))

    for file in VirSorter_123:
        category = int(file.split('cat-')[1][0])
        with open(file, 'r') as file_fasta:  # TODO read each second line
            for line in file_fasta:
                if line[0] == '>':
                    name = line.strip().split('VIRSorter_')[1]
                    if 'circular' in name:
                        name_modified = name.split('-circular')[0]
                        VirSorted_defined[name_modified] = str(category * 10)  # for circular: <category>0
                    else:
                        name_modified = name.split('-cat_')[0]
                        VirSorted_defined[name_modified] = str(category)  # for non circular: <category>

    for file in VirSorter_prophages:
        category = int(file.split('cat-')[1][0])
        with open(file, 'r') as file_fasta:  # TODO read each second line
            for line in file_fasta:
                if line[0] == '>':
                    line = line.strip().split('VIRSorter_')[1]
                    line = line.split('_gene_')
                    name = re.sub(r"[.,:; ]", "_", line[0])
                    suffix = '_gene_'.join(['']+line[1:])
                    VirSorted_prophages[name] = suffix

    return VirSorted_prophages, VirSorted_defined


def virus_parser(**kwargs):
    HC_viral_predictions, LC_viral_predictions, prophage_predictions = [[] for _ in range(3)]
    HC_viral_predictions_names, LC_viral_predictions_names, prophage_predictions_names = ['' for _ in range(3)]

    # VirFinder processing
    VF_high_ids_set, VF_low_ids_set = VF_reading(kwargs["VF_output"])

    if len(glob.glob(os.path.join(kwargs["VS_output"], "*.fasta"))) > 0:
        # VirSorter reading
        VirSorted_prophages, VirSorted_defined = VS_reading(kwargs["VS_output"])

        # Assembly.fasta processing
        for record in SeqIO.parse(kwargs["assembly_file"], "fasta"):
            vs_id = re.sub(r"[.,:; ]", "_", record.id)
            if vs_id in VirSorted_defined:
                suff = '1_'
                if record.id in VF_high_ids_set:  # _11_H_
                    suff = '_1' + suff + 'H_'
                elif record.id in VF_low_ids_set:  # _11_L_
                    suff = '_1' + suff + 'L_'
                else:  # not defined by VirFinder
                    suff = '_0' + suff
                suff += VirSorted_defined[vs_id][0]  # [0/1]1_[H/L]?_[category]_[circular]?
                if len(VirSorted_defined[vs_id]) > 1:  # circular
                    suff += '_circular'

                record.id += suff

                if VirSorted_defined[vs_id][0] == '1' or VirSorted_defined[vs_id][0] == '2':  # category 1,2
                    HC_viral_predictions_names += record.description + '\n'
                    record.description = ''
                    HC_viral_predictions.append(record)

                elif VirSorted_defined[vs_id][0] == '3':  # category 3
                    if record.id in VF_high_ids_set.union(VF_low_ids_set):  # defined by VirFinder
                        LC_viral_predictions_names += record.description + '\n'
                        record.description = ''
                        LC_viral_predictions.append(record)

            elif vs_id not in VirSorted_prophages:  # not defined by VirSorter
                suff = '0_'
                if record.id in VF_high_ids_set:  # _10_H
                    suff = '_1' + suff + 'H'
                    record.id += suff
                    LC_viral_predictions_names += record.description + '\n'
                    record.description = ''
                    LC_viral_predictions.append(record)


            elif vs_id in VirSorted_prophages:  # Prophages
                record.id += VirSorted_prophages[vs_id]
                prophage_predictions_names += record.description + '\n'
                record.description = ''
                prophage_predictions.append(record)

    print(len(HC_viral_predictions), len(LC_viral_predictions), len(prophage_predictions))
    return [HC_viral_predictions, LC_viral_predictions, prophage_predictions, \
            HC_viral_predictions_names, LC_viral_predictions_names, prophage_predictions_names]


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Write fasta files with predicted _viral contigs sorted in categories and putative prophages")
    parser.add_argument("-a", "--assemb", dest="assemb", help="Metagenomic assembly fasta file", required=True)
    parser.add_argument("-f", "--vfout", dest="finder", help="Absolute or relative path to VirFinder output file",
                        required=True)
    parser.add_argument("-s", "--vsdir", dest="sorter",
                        help="Absolute or relative path to directory containing VirSorter output", required=True)
    parser.add_argument("-o", "--outdir", dest="outdir",
                        help="Absolute or relative path of directory where output _viral prediction files should be stored (default: cwd)",
                        default=".")
    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()

        viral_predictions = virus_parser(assembly_file=args.assemb, VF_output=args.finder, VS_output=args.sorter)

        if sum([len(x) for x in viral_predictions]) > 0:
            if len(viral_predictions[0]) > 0:
                directory = os.path.join(args.outdir, 'High_confidence')
                if not os.path.exists(directory):
                    os.makedirs(directory)
                SeqIO.write(viral_predictions[0], os.path.join(directory, "High_confidence_putative_viral_contigs.fna"), "fasta")
                with open(os.path.join(directory, "High_confidence_putative_names.fna"), 'w') as high_names:
                    high_names.write(viral_predictions[3])

            if len(viral_predictions[1]) > 0:
                directory = os.path.join(args.outdir, 'Low_confidence')
                if not os.path.exists(directory):
                    os.makedirs(directory)
                SeqIO.write(viral_predictions[1], os.path.join(directory, "Low_confidence_putative_viral_contigs.fna"), "fasta")
                with open(os.path.join(directory, "Low_confidence_putative_names.fna"), 'w') as low_names:
                    low_names.write(viral_predictions[4])

            if len(viral_predictions[2]) > 0:
                directory = os.path.join(args.outdir, 'Putative_prophages')
                if not os.path.exists(directory):
                    os.makedirs(directory)
                SeqIO.write(viral_predictions[2], os.path.join(directory, "Putative_prophages.fna"), "fasta")
                with open(os.path.join(directory, "Putative_prophages_names.fna"), 'w') as proph_names:
                    proph_names.write(viral_predictions[5])

        else:
            print("Overall, no putative _viral contigs or prophages were detected in the analysed metagenomic assembly")
    """
    viral_predictions = virus_parser(assembly_file="../../../workflows/Files_viral/chunk_1_filt500bp.fasta",
                                     VF_output="../../../workflows/Files_viral/VirFinder_output.tsv",
                                     VS_output="../../../workflows/Files_viral/Predicted_viral_sequences")
    """