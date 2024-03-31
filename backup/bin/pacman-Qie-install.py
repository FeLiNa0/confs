#!/usr/bin/env python3
import argparse
import subprocess


def download_Qie_contents(contents):
    names = []
    for line in contents.split('\n'):
        is_name = line.startswith('Name ')
        if not is_name:
            continue
        split_name_line = line.split()
        if len(split_name_line) != 3:
            print('malformed line', line)
            continue
        name = split_name_line[2]
        names.append(name)

    names.sort()
    if not names:
        print('no package names found')
        return

    print(' '.join(names))


def main():
    parser = argparse.ArgumentParser(description='Install from pacman -Qie backup file.')
    parser.add_argument('fname', metavar='fname', type=str, nargs=1,
                     help='file containing output of pacman -Qie')
    args = parser.parse_args()

    filename = args.fname[0]
    with open(filename) as qie_file:
        download_Qie_contents(qie_file.read())


if __name__ == "__main__":
    main()
