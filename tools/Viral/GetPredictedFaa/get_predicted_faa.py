from Bio import SeqIO
import os
import glob
import sys
import re
import argparse


def choose_predictions(wanted_folder, file_faa):
    file_wanted = [cur_file for cur_file in os.listdir(wanted_folder) if 'names' in cur_file][0]
    file_wanted_name = wanted_folder + '/' + file_wanted
    print(os.listdir(wanted_folder))
    out_name = '_'.join(os.path.basename(file_wanted_name).split('_')[:2] + ['filtered.faa'])
    namesSet = set([line.rstrip('\n') for line in open(file_wanted_name)])

    with open(out_name, 'w') as file_out:
        seqiter = SeqIO.parse(open(file_faa), 'fasta')
        for seq in seqiter:
            search_id = re.compile(r"([0-9A-Za-z._-]+cov-[0-9.]+)_([0-9_+-]+)")
            name = search_id.search(seq.id).group(1)
            if name in namesSet:
                SeqIO.write(seq, file_out, "fasta")


if __name__ == "__main__":

    sys.stderr.write('taking_faa_predictions_from_input.FAA_according_list_with_potential_names')

    parser = argparse.ArgumentParser(description="taking_faa_predictions_from_input.FAA_according_list_with_potential_names")
    parser.add_argument("-w", dest="wanted_folder", help="Folder with file of wanted names of contigs", required=True)
    parser.add_argument("-p", dest="predicted_file", help="FAA file with all predicted contigs",
                        required=True)
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    else:
        args = parser.parse_args()
        choose_predictions(args.wanted_folder, args.predicted_file)

    #choose_predictions("../ParsingPredictions/High_confidence/", "../input/chunk_1.faa")