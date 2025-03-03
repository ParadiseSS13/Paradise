import argparse
import glob
import pathlib
import traceback
import yaml
from time import time
from concurrent.futures import ProcessPoolExecutor

from . import dmm, lint
from .error import MaplintError

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def process_dmm(map_filename) -> list[MaplintError]:
    problems: list[MaplintError] = []

    with open(map_filename, "r") as file:
        try:
            map_data = dmm.parse_dmm(file)
        except MaplintError as error:
            problems.append(error)
            # No structured data to lint.
            return problems

        map_path = pathlib.Path(map_filename)
        for lint_name, lint in lints.items():
            try:
                if map_path in lint.exclude_files:
                    continue
                problems.extend(lint.run(map_data))
                print(map_path)
            except KeyboardInterrupt:
                raise
            except Exception as e:
                problems.append(MaplintError(
                    f"An exception occurred, this is either a bug in maplint or a bug in a lint. \n{traceback.format_exc()}",
                    lint_name,
                ))

    return map_filename, problems

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

    # this is gross, but we can't use ProcessPoolExecutor with lambdas or closures
    global lints
    lints = {}

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

    map_files = args.maps or glob.glob("_maps/**/*.dmm", recursive = True)
    all_failures: list[MaplintError] = []
    print("maplint started")
    start = time()
    with ProcessPoolExecutor(max_workers=4) as executor:
        try:
            for map_filename, failures in executor.map(process_dmm, map_files):
                print(map_filename, failures)
                all_failures.append((map_filename, failures))
        except Exception as e:
            print("FUCK", e)
            raise e
        
    # for map_filename, failures in map(process_dmm, map_files):
    #     print(map_filename, failures)
    #     all_failures.append((map_filename, failures))

    for map_filename, failures in all_failures:
        print(map_filename, end = " ")
        if not failures:
            print(green("OK"))
        else:
            print(red("X"))
            any_failed = True
        for failure in failures:
            print_maplint_error(failure, github_error_style)
    print(f"maplint completed in {time() - start:<.2f} seconds")

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
