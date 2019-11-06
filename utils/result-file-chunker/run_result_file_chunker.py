#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2019 EMBL - European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import argparse
import logging
import sys
import os

from chunkTSVFileUtil import ChunkTSVFileUtil
from chunkFastaResultFileUtil import ChunkFASTAResultFileUtil

__author__ = 'Maxim Scheremetjew'

"""
    [ResultFiles]
    i5ChunkedFileLineNumber = 10000000
    i5UnchunkedFileSizeCutoffInMB = 2253
    chunkedFileSizeMaxInMB = 520
    chunkedFileSizeMinInMB = 480
    interproscanFastaDefaultTargetSize = 1819           # don't have, was for 'interproscan.fasta'
    pCDSFastaDefaultTargetSize = 1847  
    noFunctionFastaDefaultTargetSize = 1853             # don't have, was for 'noFunction.fasta' (LSU, SSU, models, mapseq ??)
    nucleotideReadsFastaDefaultTargetSize = 1980        # ACC_FASTA.fasta.gz
    cdsFaaDefaultTargetSize = 1350
    cdsUnannotatedFaaDefaultTargetSize = 1442           # don't have
    cdsUnannotatedFfnDefaultTargetSize = 1980           # don't have
    cdsAnnotatedFaaDefaultTargetSize = 1442             # don't have
    cdsAnnotatedFfnDefaultTargetSize = 1980             # dont't have
"""

DEFAULT_COMPRESSION_LEVEL = 6

chunking_settings = {
    'TableChunkedFileLineNumber': 10000000,          # all tsv tables
    'TableUnchunkedFileSizeCutoffInMB': 2253,
    'chunkedFileSizeMaxInMB': 520,
    'chunkedFileSizeMinInMB': 480,
    'FaaFastaDefaultTargetSize': 1442,
    'FfnFastaDefaultTargetSize': 1980
}


def parse_args(argv):
    parser = argparse.ArgumentParser(
        description='Tool which chunks different types of pipeline result files (e.g. FASTA or TSV formatted)')
    parser.add_argument('infile', help="Input file which needs chunking.")
    parser.add_argument('file-type', choices=['fasta', 'tsv'], default='fasta')
    parser.add_argument('type', choices=['p', 'n'], default='n')
    parser.add_argument('-v', '--verbose', action='store_true')
    return parser.parse_args(argv)


def chunk_tsv_file(infile, outdir):
    line_number = chunking_settings['TableChunkedFileLineNumber']
    cutoff = chunking_settings['TableUnchunkedFileSizeCutoffInMB']
    tsv_file_chunker = ChunkTSVFileUtil(infile=infile, line_number=line_number,
                                        cutoff=float(cutoff), outdir=outdir)
    tsv_file_chunker.chunk_tsv_result_file()


def chunk_fasta_file(infile, fasta_type, outdir):
    if fasta_type == 'n':
        cutoff = chunking_settings["FfnFastaDefaultTargetSize"]
    else:
        cutoff = chunking_settings["FaaFastaDefaultTargetSize"]
    tool_path = 'gt'
    resultFileSuffix = os.path.basename(infile)
    fasta_file_chunker = ChunkFASTAResultFileUtil(infile=infile,
                                                  resultFileSuffix=resultFileSuffix,
                                                  targetSize=cutoff,
                                                  tool_path=tool_path,
                                                  outdir=outdir)
    fasta_file_chunker.chunkFASTAResultFile()


def chunk_file(infile, file_format, fasta_type, outdir):
    if file_format == 'tsv':
        chunk_tsv_file(infile, outdir)
    elif file_format == 'fasta':
        chunk_fasta_file(infile, fasta_type, outdir)
    else:
        logging.warning("Unsupported file type.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert fastq to fasta")
    parser.add_argument("-i", "--input", dest="input", help="Input fastq file", required=True)
    parser.add_argument("-f", "--format", dest="format", help="Output fasta file", required=True)
    parser.add_argument("-t", "--type", dest="type", help="-n for nucleotide fasta, -p for protein fasta")
    parser.add_argument("-o", "--outdir", dest="outdir", help="Name of output folder", required=True)


    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        chunk_file(args.input, args.format, args.type, args.outdir)
