#!/usr/bin/env python
input = '/Users/kates/Desktop/interpo_united'

contigs = {}
with open(input, 'r') as file_in:
    for line in file_in:
        line = line.strip().split('\t')
        if line[0] not in contigs:
            contigs[line[0]] = []
        contigs[line[0]].append('\t'.join(line))

for key in contigs:
    for line in contigs[key]:
        with open(key, 'w') as file_out:
            file_out.write(line)
    file_out.close()
