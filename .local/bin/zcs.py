#! /usr/bin/env python3

import os
import sys

suffix = [
    'tex',
    'bib',
]

skip_line_starts = [
    '%',
]

def count(file_path):
    zc = 0
    for line in open(file_path).readlines():
        if len(line.strip()) >0 and line.strip()[0] not in skip_line_starts:
            for char in line:
                if ord(char) >= 0x4e00 and ord(char) <= 0x9fa5:
                    zc += 1
    return zc


def dir_walk(path):
    zc = 0
    for p, d, fs in os.walk(path):
        for f in fs:
            if f.split('.')[-1] in suffix:
                zc += count(os.path.join(p,f))
    return zc

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print(
'''Usage: zcs.py FILE
    Counting chinese characters in tex files.
''')
        exit(1)
    obj_dir = sys.argv[1]
    if os.path.isdir(obj_dir):
        zc = dir_walk(obj_dir)
    elif os.path.isfile(obj_dir):
        zc = count(obj_dir)
    else:
        exit(2)
    print(zc)
