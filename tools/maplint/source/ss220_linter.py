import argparse
import glob
import pathlib
import traceback
import yaml

from . import dmm, lint
from .error import MaplintError
from .__main__ import process_dmm, print_maplint_error, print_error, green, red

def main(args):
    github_error_style = args.github
    any_failed = False

    lints: dict[str, lint.Lint] = {}

    lint_base = pathlib.Path(__file__).parent.parent / "ss220_lints"
    lint_filenames = lint_base.glob("*.yml")

    for lint_filename in lint_filenames:
        try:
            lints[lint_filename] = lint.Lint(yaml.safe_load(lint_filename.read_text()))
        except Exception:
            print_error("Error loading modular lint file.", str(lint_filename), 1, github_error_style)
            traceback.print_exc()
            any_failed = True

    for map_filename in glob.glob("_maps/map_files220/**/*.dmm", recursive = True):
        print(map_filename, end = " ")

        success = True
        all_failures: list[MaplintError] = []

        try:
            problems = process_dmm(map_filename, lints)
            if len(problems) > 0:
                success = False
                all_failures.extend(problems)
        except KeyboardInterrupt:
            raise
        except Exception:
            success = False

            all_failures.append(MaplintError(
                f"An exception occurred, this is either a bug in maplint or a bug in a lint.' {traceback.format_exc()}",
                map_filename,
            ))

        if success:
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

    parser.add_argument("--github", action="store_true")

    args = parser.parse_args()
    main(args)
