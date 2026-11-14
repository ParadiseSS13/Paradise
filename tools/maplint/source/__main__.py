import argparse
import glob
import itertools
import pathlib
import traceback
import yaml
from concurrent.futures import ProcessPoolExecutor

from . import lint
from .check import check_map
from .error import MaplintError

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def print_error(message: str, filename: str, line_number: int, github_error_style: bool):
    if github_error_style:
        print(f"::error file={filename},line={line_number},title=DMM Linter::{message}")
    else:
        print(red(f"- Error parsing {filename} (line {line_number}): {message}"))

def print_maplint_error(error: MaplintError, github_error_style: bool):
    print_error(
        f"{f'(in pop {error.pop_id}) ' if error.pop_id else ''}{f'(at {error.coordinates}) ' if error.coordinates else ''}{error}" + (f"\n  {error.help}" if error.help is not None else ""),
        error.file_name,
        error.line_number,
        github_error_style,
    )

def main(args):
    any_failed = False
    github_error_style = args.github

    lints: dict[str, lint.Lint] = {}

    lint_base = pathlib.Path(__file__).parent.parent / "lints"
    lint_filenames = []
    if args.lints is None:
        lint_filenames = lint_base.glob("*.yml")
    else:
        lint_filenames = [lint_base / f"{lint_name}.yml" for lint_name in args.lints]

    for lint_filename in lint_filenames:
        try:
            lints[lint_filename] = lint.Lint(yaml.safe_load(lint_filename.read_text()))
        except MaplintError as error:
            print_maplint_error(error, github_error_style)
            any_failed = True
        except Exception:
            print_error("Error loading lint file.", lint_filename, 1, github_error_style)
            traceback.print_exc()
            any_failed = True

    map_filenames = args.maps or glob.glob("_maps/**/*.dmm", recursive = True)

    # Maps are checked in parallel, but the results still print in order
    with ProcessPoolExecutor() as executor:
        results = executor.map(check_map, map_filenames, itertools.repeat(lints))
        for map_filename, all_failures in zip(map_filenames, results):
            print(map_filename, end = " ")

            if len(all_failures) == 0:
                print(green("OK"))
            else:
                print(red("X"))
                any_failed = True

            for failure in all_failures:
                print_maplint_error(failure, github_error_style)

    if any_failed:
        exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog = "maplint",
        description = "Checks for common errors in maps.",
    )

    parser.add_argument("maps", nargs = "*")
    parser.add_argument("--lints", nargs = "*")
    parser.add_argument("--github", action='store_true')

    args = parser.parse_args()

    main(args)
