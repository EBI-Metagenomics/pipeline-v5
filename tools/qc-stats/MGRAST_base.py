#!/usr/bin/env python

import os, re, sys, math, subprocess, random
from collections import defaultdict
from optparse import OptionParser
from Bio import SeqIO
from Bio.SeqIO.QualityIO import FastqGeneralIterator

__doc__ = """
Calculate statistics for fasta files.
OUTPUT:
  bp_count
  sequence_count
  average_length
  standard_deviation_length
  length_min
  length_max
  average_gc_content
  standard_deviation_gc_content
  average_gc_ratio
  standard_deviation_gc_ratio
  ambig_char_count
  ambig_sequence_count
  average_ambig_chars
  sequence_type"""

IUPAC = [
    'a', 'c', 'g', 't', 'u', 'r', 'y', 's', 'w', 'k', 'm', 'b', 'd', 'h', 'v', 'n', 'x',
    'A', 'C', 'G', 'T', 'U', 'R', 'Y', 'S', 'W', 'K', 'M', 'B', 'D', 'H', 'V', 'N', 'X',
    '-', ' ', '\n'
]


def sum_map(aMap):
    total = 0
    for k, v in aMap.iteritems():
        total += (float(k) * v)
    return total


def seq_iter(file_hdl, stype):
    if stype == 'fastq':
        return FastqGeneralIterator(file_hdl)
    else:
        return SeqIO.parse(file_hdl, stype)


def split_rec(rec, stype):
    if stype == 'fastq':
        return rec[0].split()[0], rec[1].upper(), rec[2]
    else:
        return rec.id, str(rec.seq).upper(), None


def get_mean_stdev(count, data):
    total = sum_map(data)
    mean = (total * 1.0) / count
    tmp = 0
    for k, v in data.iteritems():
        for i in range(0, v):
            dev = float(k) - mean
            tmp += (dev * dev)
    return mean, math.sqrt(tmp / count)


def get_seq_type(size, data):
    kset = []
    total = sum(data.values())
    for i in range(1, size + 1):
        kset.append(sub_kmer(i, total, data))
    # black box logic
    if (kset[15] < 9.8) and (kset[10] < 6):
        return "Amplicon"
    else:
        return "WGS"


def percentbin(table):
    TABLE = dict()
    sumval = sum(table.values())
    for entry in table:
        TABLE[entry] = float(int(table[entry] * 1000.0 / (sumval))) / 10
    return TABLE


def sub_kmer(pos, total, data):
    sub_data = defaultdict(int)
    entropy = 0
    for kmer, num in data.iteritems():
        sub_data[kmer[:pos]] += num
    for skmer, snum in sub_data.iteritems():
        sratio = float(snum) / total
        entropy += (-1 * sratio) * math.log(sratio, 2)
    return entropy


def output_bins(data, outf):
    out_hdl = open(outf, "w")
    keys = data.keys()
    keys.sort(lambda a, b: cmp(float(a), float(b)))
    for k in keys:
        out_hdl.write(str(k) + "\t" + str(data[k]) + "\n")
    out_hdl.close()


# function added by H. Denise to bin results for graphs
def binning(data, type):
    res = {}
    # get higher value and generate bin limits depending on data type
    if type == 0:
        maxval = sorted(data)[len(data) - 1]
        minval = sorted(data)[0]
        datarange = maxval - minval
    else:
        datarange = 100
        minval = 0
    # get the bin size
    nb = int(datarange / 20) + (datarange % 20 > 0)
    # initialise dictionary with lowest value
    res[minval + nb] = data[minval]
    # go through dictionnary and bin the data
    for d in sorted(data):
        # deal with type of data (%GC are recognized as text otherwise)
        if type == 1:
            D = float(d)
        else:
            D = d
        # go through the bins and bin accordingly
        for i in range(20):
            # define bin borders
            lowerval = minval + nb * (i)
            upperval = minval + nb * (i + 1)
            # bin
            if D > lowerval and D <= upperval:
                if (upperval) in res:
                    res[upperval] = res[upperval] + data[d]
                else:
                    res[upperval] = data[d]
    return res


def count_sequences(infile, sequence_type):
    if sequence_type == 'fasta':
        cmd = ['grep', '-c', '^>', infile]
    elif sequence_type == 'fastq':
        cmd = ['wc', '-l', infile]
    else:
        sys.stderr.write("%s is invalid %s file\n" % (infile, sequence_type))
        exit(1)
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = proc.communicate()
    if proc.returncode != 0:
        raise IOError("%s\n%s" % (" ".join(cmd), stderr))
    slen = stdout.strip()
    if not slen:
        sys.stderr.write("%s is invalid %s file\n" % (infile, sequence_type))
        exit(1)
    if sequence_type == 'fastq':
        slenNum = int(slen.split()[0]) / 4
    else:
        slenNum = int(slen)
    return slenNum


usage = "usage: %prog [options] -i input_fasta" + __doc__


def main(args):
    parser = OptionParser(usage=usage)
    parser.add_option("-i", "--input", dest="input", default=None, help="Input sequence file")
    parser.add_option("-o", "--output", dest="output", default=None,
                      help="Output stats file, if not called prints to STDOUT")
    parser.add_option("-t", "--type", dest="type", default="fasta",
                      help="Input file type. Must be fasta or fastq [default 'fasta']")
    parser.add_option("-l", "--length_bin", dest="len_bin", metavar="FILE", default=None,
                      help="File to place length bins [default is no output]")
    parser.add_option("-g", "--gc_percent_bin", dest="gc_bin", metavar="FILE", default=None,
                      help="File to place % gc bins [default is no output]")
    parser.add_option("-f", "--fast", dest="fast", default=False, action="store_true",
                      help="Fast mode, only calculate length stats")
    parser.add_option("-s", "--seq_type", dest="seq_type", default=False, action="store_true",
                      help="Guess sequence type [wgs|amplicon] from kmer entropy")
    parser.add_option("-m", "--seq_max", dest="seq_max", type="int",
                      help="max number of seqs to process (for QC stats) [default all]")
    parser.add_option("-c", "--ignore_comma", dest="ignore_comma", default=False, action="store_true",
                      help="Ignore commas in header ID [default is to throw error]")
    # option added for H. Denise to generate data for nucleotide histogram
    parser.add_option("-d", "--base_distribution_output", dest="base_distrib", metavar="FILE", default=None,
                      help="File to place base distribution data [default is no output]")

    # check options
    (opts, args) = parser.parse_args()
    if not opts.input:
        sys.stderr.write("[error] missing input file\n")
        os._exit(1)
    if (opts.type != 'fasta') and (opts.type != 'fastq'):
        sys.stderr.write("[error] file type '%s' is invalid\n" % opts.type)
        os._exit(1)
    input_file = opts.input
    sequence_type = opts.type
    number_of_seqs = count_sequences(input_file, sequence_type)

    if opts.seq_max:
        seqper = (opts.seq_max * 1.0) / number_of_seqs
        Seqnum = opts.seq_max
    else:
        seqper = 1
        Seqnum = number_of_seqs

    # set variables
    seqnum = 0
    countseq = 0
    lengths = defaultdict(int)
    gc_perc = defaultdict(int)
    gc_ratio = defaultdict(int)
    ambig_char = 0
    ambig_seq = 0
    kmer_len = 16
    kmer_num = 0
    prefix_map = defaultdict(int)
    in_hdl = open(opts.input, "rU")
    # variables added by H. Denise to generate data for nucleotide histogram
    base_distribution = {}  # base pos dictionary
    charseq = {'A': 0, 'T': 0, 'G': 0, 'C': 0, 'N': 0}  # dictionary counter for bases

    # test valid sequence file
    first_char = in_hdl.read(1)
    if (opts.type == 'fasta') and (first_char != '>'):
        sys.stderr.write("[error] invalid fasta file, first character must be '>'\n")
        os._exit(1)
    elif (opts.type == 'fastq') and (first_char != '@'):
        sys.stderr.write("[error] invalid fastq file, first character must be '@'\n")
        os._exit(1)

    # parse sequences
    in_hdl.seek(0)
    try:
        for rec in seq_iter(in_hdl, opts.type):
            head, seq, qual = split_rec(rec, opts.type)
            if countseq == Seqnum or seqper < random.random():
                continue
            else:
                countseq += 1
            if (opts.type == 'fasta') and (re.match('^\s', rec.description)):
                sys.stderr.write(
                        "[error] invalid fasta file, first character following '>' in header must be non-whitespace\n")
                os._exit(1)
            if (not opts.ignore_comma) and ("," in head):
                sys.stderr.write("[error] invalid sequence file, header may not contain a comma (,)\n")
                os._exit(1)

            slen = len(seq)
            seqnum += 1
            charnum = 0  # variable added by H. Denise to generate data for nucleotide histogram
            lengths[slen] += 1

            if not opts.fast:
                if opts.type == 'fastq':
                    for q in qual:
                        ascii_value = ord(q)
                        if ascii_value < 33 or ascii_value > 126:
                            sys.stderr.write(
                                    "[error] quality value with ASCII value: %d in sequence: %s (sequence number %d) is not within ASCII range 33 to 126\n" % (
                                        ascii_value, head, seqnum))
                            os._exit(1)
                char = {'A': 0, 'T': 0, 'G': 0, 'C': 0, 'N': 0}
                for i, c in enumerate(seq):
                    if c not in IUPAC:
                        try:
                            ord(c)
                            sys.stderr.write(
                                    "[error] character '%s' (position %d) in sequence: %s (sequence number %d) is not a valid IUPAC code\n" % (
                                        c, i, head, seqnum))
                            os._exit(1)
                        except:
                            sys.stderr.write(
                                    "[error] non-ASCII character at position %d in sequence: %s (sequence number %d) is not a valid IUPAC code\n" % (
                                        i, head, seqnum))
                            os._exit(1)
                    charnum += 1
                    # loop added by H. Denise to generate data for nucleotide histogram. Initialise dictionary when new pos is encountered
                    if charnum not in base_distribution:
                        base_distribution[charnum] = {'A': 0, 'T': 0, 'G': 0, 'C': 0, 'N': 0}  # initialisation
                    if c in char:
                        char[c] += 1
                        base_distribution[charnum][
                            c] += 1  # added by H. Denise to generate data for nucleotide histogram. Increment count at looked up position
                atgc = char['A'] + char['T'] + char['G'] + char['C']
                ambig = slen - atgc;
                gc_p = "0"
                gc_r = "0"
                if atgc > 0:
                    gc_p = "%.1f" % ((1.0 * (char['G'] + char['C']) / atgc) * 100)
                if (char['G'] + char['C']) > 0:
                    gc_r = "%.1f" % (1.0 * (char['A'] + char['T']) / (char['G'] + char['C']))
                gc_perc[gc_p] += 1
                gc_ratio[gc_r] += 1
                if ambig > 0:
                    ambig_char += ambig
                    ambig_seq += 1
            if opts.seq_type and (slen >= kmer_len) and (kmer_num < opts.seq_max):
                prefix_map[seq[:kmer_len]] += 1
                kmer_num += 1
    except ValueError as e:
        sys.stderr.write("[error] %s\n" % e)
        os._exit(1)

    # get stats
    if seqnum == 0:
        sys.stderr.write("[error] invalid %s file, unable to find sequence records\n" % opts.type)
        os._exit(1)
    len_mean, len_stdev = get_mean_stdev(seqnum, lengths)
    min_len = min(lengths.iterkeys())
    max_len = max(lengths.iterkeys())
    stat_text = ["bp_count\t%d" % sum_map(lengths),
                 "sequence_count\t%d" % seqnum,
                 "average_length\t%.3f" % len_mean,
                 "standard_deviation_length\t%.3f" % len_stdev,
                 "length_min\t%d" % min_len,
                 "length_max\t%d" % max_len]

    if not opts.fast:
        gcp_mean, gcp_stdev = get_mean_stdev(seqnum, gc_perc)
        gcr_mean, gcr_stdev = get_mean_stdev(seqnum, gc_ratio)
        stat_text.extend(["average_gc_content\t%.3f" % gcp_mean,
                          "standard_deviation_gc_content\t%.3f" % gcp_stdev,
                          "average_gc_ratio\t%.3f" % gcr_mean,
                          "standard_deviation_gc_ratio\t%.3f" % gcr_stdev,
                          "ambig_char_count\t%d" % ambig_char,
                          "ambig_sequence_count\t%d" % ambig_seq,
                          "average_ambig_chars\t%.3f" % ((ambig_char * 1.0) / seqnum)])
    if opts.seq_type:
        seq_type_guess = get_seq_type(kmer_len, prefix_map)
        stat_text.append("sequence_type\t%s" % seq_type_guess)

    # output stats
    if not opts.output:
        sys.stdout.write("\n".join(stat_text) + "\n")
    else:
        out_hdl = open(opts.output, "w")
        out_hdl.write("\n".join(stat_text) + "\n")
        out_hdl.close()
    # added by H. Denise to generate data for nucleotide histogram. Write to file base count as % of all bases at each position
    if opts.base_distrib:
        out_bd = open(opts.base_distrib, "w")
        out_bd.write("pos\tN\tG\tC\tT\tA\n")
        if len(base_distribution) > 500:
            charnum = 501
        else:
            charnum = len(base_distribution) + 1
        print charnum
        for i in range(1, charnum):
            sum = base_distribution[i]['N'] + base_distribution[i]['G'] + base_distribution[i]['C'] + \
                  base_distribution[i]['T'] + base_distribution[i]['A']
            out_bd.write(str(i) + "\t" + str(round(float(base_distribution[i]['N'] * 100) / sum, 2)) + "\t" + str(
                    round(float(base_distribution[i]['G'] * 100) / sum, 2)) + "\t" + str(
                    round(float(base_distribution[i]['C'] * 100) / sum, 2)) + "\t" + str(
                    round(float(base_distribution[i]['T'] * 100) / sum, 2)) + "\t" + str(
                    round(float(base_distribution[i]['A'] * 100) / sum, 2)) + "\n")
        out_bd.close()

    # get binned stats
    if opts.len_bin:
        output_bins(lengths, opts.len_bin)
        # call function added by H. Denise to bin results for graphs
        LENGTHS = binning(lengths, 0)
        LENGTHS_PERC = percentbin(LENGTHS)
        # write output to file
        output_bins(LENGTHS, opts.len_bin + "_bin")
        output_bins(LENGTHS_PERC, opts.len_bin + "_pcbin")
    if opts.gc_bin and (not opts.fast):
        output_bins(gc_perc, opts.gc_bin)
        # call function added by H. Denise to bin results for graphs
        GC = binning(gc_perc, 1)
        GC_PERC = percentbin(GC)
        # write output to file
        output_bins(GC, opts.gc_bin + "_bin")
        output_bins(GC_PERC, opts.gc_bin + "_pcbin")

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
