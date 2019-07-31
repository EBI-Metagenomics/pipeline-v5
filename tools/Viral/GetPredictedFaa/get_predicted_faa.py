from Bio import SeqIO
import os
import sys
import argparse


def choose_predictions(wanted_file, file_faa):
    wanted = [line.strip() for line in open(wanted_file, 'r')]
    seqiter = SeqIO.parse(open(file_faa), 'fasta')
    out_name = '_'.join(os.path.splitext(os.path.basename(wanted_file))[0].split('_')[:-1] + ['predicted'])

    with open(out_name + '.faa', 'w') as file_out:
        for seq in seqiter:
            for wanted_id in wanted:
                if wanted_id + '_' in seq.id:
                    SeqIO.write(seq, file_out, "fasta")


if __name__ == "__main__":
    sys.stderr.write('taking_faa_predictions_from_input.FAA_according_list_with_potential_names')

    parser = argparse.ArgumentParser(description="taking_faa_predictions_from_input.FAA_according_list_with_potential_names")
    parser.add_argument("-w", dest="wanted_file", help="Relative or absolute path to input fasta file", required=True)
    parser.add_argument("-p", dest="predicted_file", help="Length threshold in kb of selected sequences (default: 5kb)",
                        required=True)
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    else:
        args = parser.parse_args()
        choose_predictions(args.wanted_file, args.predicted_file)