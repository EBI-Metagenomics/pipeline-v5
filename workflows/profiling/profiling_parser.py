#!/usr/bin/env python

import sys
import argparse
import os

def memory_convert(memory):

    memory_dict = {'MiB': 1048576, 'Mbytes': 10**6, 'Gbytes': 10**9 }

    number = ''
    for i in range(len(memory)):
        if memory[i].isdigit():
            number += memory[i]
            index = i
    if memory[index+1] == ' ':
        index = index + 2
    else:
        index += 1
    units = memory[index:].split(';')[0]

    out_str = '\t'.join([number, units]) + '\t'

    if units in memory_dict:
        size = int(int(number) * memory_dict[units] / 1048576)  # in MiB
        out_str += '\t'.join([str(size), 'MiB'])
    else:
        out_str += '\t'.join([number, units])
        print(out_str)
    return out_str


def get_profiling(file_name):
    # parsing
    list_profiling = []
    prefix = os.path.basename(file_name)
    with open(file_name, 'r') as file_in:
        for line in file_in:
            line = line.strip()
            memory = line.split('memory ')[-1]
            memory_line = memory_convert(memory)
            position = line.find('.cwl')
            cur_position = line.find('.cwl')
            while line[cur_position] != '/':
                cur_position -= 1
            statistics = '\t'.join([line[cur_position+1:position+4], memory_line])
            list_profiling.append(statistics)
    list_profiling = set(list_profiling)

    # set maximum memory
    dict_steps = {}
    for item in sorted(list(list_profiling)):
        step = item.split('\t')[0]
        memory_step = item.split('\t')[3]
        if step not in dict_steps:
            dict_steps[step] = 0
        if dict_steps[step] < int(memory_step):
            dict_steps[step] = int(memory_step)

    # write summary for each step
    print('writting profiling_final_all')
    with open(prefix + '_profiling_final_all.tsv', 'w') as file_out:
        for item in sorted(list(list_profiling)):
            file_out.write(item + '\n')

    # write summary with max memory
    print('writting profiling_final_maximum')
    with open(prefix + '_profiling_final_maximum.tsv', 'w') as file_out:
        for item in sorted(dict_steps):
            file_out.write('\t'.join([item, str(dict_steps[item]), 'MiB']) + '\n')


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert table to CSV")
    parser.add_argument("-i", "--input", dest="input", help="Input table", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        get_profiling(args.input)