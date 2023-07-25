# Naive search for illegal files. Has no semantic knowledge, just a lexical
# search for specific endings in a .dme
#
# This is basically a slightly edited verison of unticked_files.py.
# Look there for precise documentation on the methods used here.
from pathlib import Path, PureWindowsPath
import argparse
import sys

INCLUDED_FILES = [
    'paradise.dme'
]

ILLEGAL_FILES = (
    '.dmm'
)

def get_illegal_files(root: Path):
    illegal_files = set()
    for includer in INCLUDED_FILES:
        with open(root / includer, 'r') as f:
            # I've tried to optimize this, but this was the best I could get. Try placing the strips elsewhere if you dare
            lines = [line for line in f.readlines() if line.rstrip('\r\n').strip('"').endswith(ILLEGAL_FILES)]
            included = [line.replace('#include ', '').rstrip('\r\n').strip('"') for line in lines]
            if(len(INCLUDED_FILES) > 1):
                print(f'Found {len(included)} illegal files in {root / includer}')
            illegal_files.update([root / Path(includer).parent / Path(PureWindowsPath(i)) for i in included])

    return illegal_files

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("root", help="paracode root directory")
    args = parser.parse_args()

    # Windows quoting behavior for directories adds trailing double-quote
    illegal_files = get_illegal_files(Path(args.root.strip('"')))
    if illegal_files:
        print(f'Found {len(illegal_files)} illegal files:')
        print('\n'.join(str(x) for x in sorted(illegal_files)))
        sys.exit(1)
    else:
        print(f'Found no .dme illegal files')
