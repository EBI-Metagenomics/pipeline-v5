#!/usr/bin/env python3

import re
import stat
import os
import sys
import json
import gzip
import argparse
import subprocess


def map_accessions(inf, outf, map, next_acc, biome, obs_biome):
    with open(inf) as fin, open(outf, 'w') as fout:
        for line in fin:
            hash, partial, seq, assembly, count, header = line.rstrip().split(' ', maxsplit=5)
            if seq in map and partial in map[seq]:
                acc = map[seq][partial]
            elif seq in map:
                acc = "MGYP%012d" % next_acc
                next_acc += 1
                map[seq][partial] = acc
            else:
                acc = "MGYP%012d" % next_acc
                next_acc += 1
                map[seq] = {}
                map[seq][partial] = acc
            if assembly in biome:
                b = biome[assembly]
            else:
                b = ''
            if not b in obs_biome:
                obs_biome[b] = 0
            obs_biome[b] += 1
            fout.write('\t'.join([acc, hash, partial, seq, assembly, count, b, header]) + '\n')
    return next_acc


def read_map_file(file):
    map = {}
    if not os.path.exists(file):
        return map
    with open(file) as fh:
        for line in fh:
            seq, partial, acc = line.rstrip().split(' ')
            if not seq in map:
                map[seq] = {}
            map[seq][partial] = acc
    return map


def next_accession(dir):
    with open(os.path.join(dir, 'max_acc')) as fmax:
        max = int(fmax.readline())
    return max + 1


def write_map_file(file, map):
    with open(file, 'w') as fh:
        for seq in map:
            for partial in map[seq]:
                fh.write(' '.join([seq, partial, map[seq][partial]]) + '\n')


def get_args(a):
    parser = argparse.ArgumentParser(prog=a[0])
    parser.add_argument('-c', '--config', action='store', dest='config', required=True, help='Tool config file')
    parser.add_argument("-v", "--verbose", help="verbose output", dest="verbosity", action="count", required=False)
    parser.add_argument("-r", "--release", help="release", dest="release", action="store", required=True)
    return vars(parser.parse_args())


def gather_files(path):
    found = []

    for root, dirs, files in os.walk(path):
        for file in files:
            if re.match('peptides_runs_counts*', file):
                found.append(os.path.join(root, file))
    return found


def process_file(file, fh, max_len):
    if file[-3:] == '.gz':
        fin = gzip.open(file, mode='rt', encoding='utf-8')
    else:
        fin = open(file, 'r')
    for line in fin:
        if len(line.split(' ', maxsplit=5)[2]) <= max_len:
            fh[line[:2]].write(line)
    fin.close()


args = get_args(sys.argv)
with open(args['config'], 'r') as fc:
    config = json.loads(fc.read())

prev_mappings = []
mapping_dir = os.path.join(config['mapping'], 'mgyp')
for pv in sorted(os.listdir(mapping_dir), reverse=True):
    if re.match('^\d{8}$', pv) and pv != args['release']:
        prev_mappings.append(pv)
if prev_mappings:
    last_map = prev_mappings[0]
else:
    last_map = None

pep_dir = config['peptides']
release_dir = os.path.join(config['releases'], args['release'])
if not os.path.exists(release_dir):
    os.mkdir(release_dir)
prev_mapping_dir = os.path.join(config['mapping'], 'mgyp', last_map)
mapping_dir = os.path.join(config['mapping'], 'mgyp', args['release'])
if not os.path.exists(mapping_dir):
    os.mkdir(mapping_dir)
biome_file = os.path.join(config['mapping'], 'biome', 'all-biomes.txt')

biome = {}

with open(biome_file) as bfh:
    for line in bfh:
        acc, b = line.rstrip().split('\t')
        biome[acc] = b

files = gather_files(pep_dir)
with open(os.path.join(release_dir, 'peptides.txt'), 'w') as fpep:
    for file in files:
        fpep.write(file + '\n')

fh = {}
next_acc = next_accession(prev_mapping_dir)

for twochar in [hex(x)[2:] + hex(y)[2:] for x in range(16) for y in range(16)]:
    fh[twochar] = open(os.path.join(release_dir, twochar + '.raw'), 'w')

for file in files:
    process_file(file, fh, config['max_pep_length'])

obs_biome = {}

for h in fh:
    fh[h].close()

for twochar in [hex(x)[2:] + hex(y)[2:] for x in range(16) for y in range(16)]:
    raw_file = os.path.join(release_dir, twochar + '.raw')
    proc_file = os.path.join(release_dir, twochar + '.txt')
    map = read_map_file(os.path.join(prev_mapping_dir, twochar))
    next_acc = map_accessions(raw_file, proc_file, map, next_acc, biome, obs_biome)
    write_map_file(os.path.join(mapping_dir, twochar), map)
    os.chmod(os.path.join(mapping_dir, twochar), stat.S_IRUSR | stat.S_IRGRP | stat.S_IROTH)
    with open(os.path.join(mapping_dir, 'max_acc'), 'w') as fmax:
        fmax.write(str(next_acc - 1))

with open(os.path.join(release_dir, 'mgy_biome_counts_' + args['release'] + '.tsv'), 'w') as fbiome:
    for b in sorted(obs_biome.items(), key=lambda x: x[1], reverse=True):
        fbiome.write(str(b[1]) + '\t' + b[0] + '\n')

os.chmod(mapping_dir, stat.S_IRUSR | stat.S_IXUSR | stat.S_IRGRP | stat.S_IXGRP)