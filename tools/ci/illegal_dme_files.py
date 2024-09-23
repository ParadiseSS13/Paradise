# Naive search for illegal files. Has no semantic knowledge, just a lexical
# search for specific endings in a .dme
#
# Illegal files are files that are allowed in the .dme by byond's standards,
# but will cause actual issues on runtime. For example, dmm files are illegal
# because they will mess with the map rotation system and z-levels in unexpected ways
#
# This is basically a slightly edited verison of unticked_files.py.
# Look there for precise documentation on the methods used here.
from pathlib import Path, PureWindowsPath
import argparse
import sys

INCLUDED_FILES = [
    'paradise.dme'
]

ILLEGAL_FILES = ( # Use a tuple here
    '.dmm',
)

def get_illegal_files(root: Path):
    illegal_file_count = 0
    for includer in INCLUDED_FILES:
        illegal_files = set()
        with open(root / includer, 'r') as f:
            # I've tried to optimize this, but this was the best I could get. Try placing the strips elsewhere if you dare
            lines = [line for line in f.readlines() if line.rstrip('\r\n').strip('"').endswith(ILLEGAL_FILES)]
            included = [line.replace('#include ', '').rstrip('\r\n').strip('"') for line in lines]
            illegal_files.update([root / Path(includer).parent / Path(PureWindowsPath(i)) for i in included])

        if len(illegal_files) >= 1:
            illegal_file_count += len(illegal_files)
            print(f'Found {len(illegal_files)} illegal files in {root / includer}:')
            print('\n'.join(str(x) for x in sorted(illegal_files)), '\n')

    return illegal_file_count

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("root", help="project root directory")
    args = parser.parse_args()

    # Windows quoting behavior for directories adds trailing double-quote
    illegal_files = get_illegal_files(Path(args.root.strip('"')))
    if illegal_files:
        print(f'Found {illegal_files} total illegal files.')
        print('Illegal files are not allowed to be included in dme files.')
        sys.exit(1)
    else:
        print('Found no illegal includes in main .dme.')
