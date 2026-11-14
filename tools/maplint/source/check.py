import pathlib
import traceback

from . import dmm, lint
from .error import MaplintError

# These live outside __main__.py so maplint's worker processes can load them

def process_dmm(map_filename, lints: dict[str, lint.Lint]) -> list[MaplintError]:
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
            except KeyboardInterrupt:
                raise
            except Exception:
                problems.append(MaplintError(
                    f"An exception occurred, this is either a bug in maplint or a bug in a lint. \n{traceback.format_exc()}",
                    lint_name,
                ))

    return problems

def check_map(map_filename, lints: dict[str, lint.Lint]) -> list[MaplintError]:
    try:
        return process_dmm(map_filename, lints)
    except KeyboardInterrupt:
        raise
    except Exception:
        return [MaplintError(
            f"An exception occurred, this is either a bug in maplint or a bug in a lint.' {traceback.format_exc()}",
            map_filename,
        )]
