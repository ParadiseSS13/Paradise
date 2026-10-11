import os
from dataclasses import dataclass, field
from enum import StrEnum
from pathlib import Path
from typing import Optional, cast

from avulto import DME
from avulto.ast import SourceLoc
import pytest
from pytest import FixtureRequest, Function, Item

GITHUB_ACTIONS = os.getenv("GITHUB_ACTIONS") == "true"

class Color(StrEnum):
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    BLUE = "\033[0;34m"
    NO_COLOR = "\033[0m"


@dataclass(frozen=True)
class LintError:
    msg: str
    file: str | None = None
    line: int | None = None
    title: str | None = None

    def to_ansi_formatted(self) -> str:
        if self.file is None:
            return f"{Color.RED}ERROR:{Color.NO_COLOR} {self.msg}"
        if self.line is None:
            return f"{Color.RED}{self.file}:{Color.NO_COLOR} {self.msg}"
        return f"{Color.RED}{self.file}:{self.line}:{Color.NO_COLOR} {self.msg}"

    def to_github_annotation(self) -> str:
        location = ""
        prefix = ""

        if self.file and self.line:
            location = f" file={self.file},line={self.line}"
            prefix = f"{self.file}:{self.line}:"

        elif self.file:
            location = f" file={self.file}"
            prefix = f"{self.file}: "

        return f"::error{location},title={self.title}::{prefix}{self.msg}"

@dataclass
class Lint:
    title: str
    errors: list[LintError] = field(default_factory=list[LintError])

    def error(self, msg: str, file: str | Path | None = None, line: int | None = None) -> None:
        self.errors.append(LintError(msg, str(file) if file is not None else None, line, self.title))

    def error_source(self, msg: str, source_loc: SourceLoc) -> None:
        self.errors.append(LintError(msg, str(source_loc.file_path), source_loc.line))


# If we're in a GitHub Actions context, write annotations alongside the default failure messages
def pytest_terminal_summary(terminalreporter: pytest.TerminalReporter) -> None:
    if not GITHUB_ACTIONS:
        return

    for report in terminalreporter.stats.get("failed", []):
        report = cast(pytest.TestReport, report)

        for name, errors in report.user_properties:
            if name != "lint_errors":
                continue

            lint_errors = cast(list[LintError], errors)

            for lint_error in lint_errors:
                terminalreporter.write_line(
                    lint_error.to_github_annotation()
                )


@pytest.hookimpl(wrapper=True)
def pytest_runtest_call(item: Item):
    yield

    if not isinstance(item, Function):
        return

    lint: Optional[Lint] = cast(Lint, item.funcargs.get("lint"))
    if lint and lint.errors:
        item.user_properties.append(("lint_errors", lint.errors))
        # TODO: Don't use ansi color codes if pytest has colors set to false
        pytest.fail("\n".join(e.to_ansi_formatted() for e in lint.errors), pytrace=False)

def get_repo_root() -> Path:
    # Start from the directory of the current script
    start_path = Path(__file__).resolve().parent

    for parent in [start_path] + list(start_path.parents):
        if (parent / '.git').is_dir():
            return parent

    raise RuntimeError("Git root directory not found.")

@pytest.fixture(scope="session")
def repo_root(request: FixtureRequest) -> Path:
    return get_repo_root()

def get_codebase_file(extension: str) -> list[Path]:
    repo_root = get_repo_root()
    return [file.relative_to(repo_root) for file in repo_root.rglob(f"*.{extension}")]

@pytest.fixture(scope="session")
def dm_files(request: FixtureRequest) -> list[Path]:
    """
    Find all .dm files recursively
    """
    return get_codebase_file("dm")

@pytest.fixture(scope="session")
def dmi_files(request: FixtureRequest) -> list[Path]:
    """
    Find all .dmi files recursively
    """
    return get_codebase_file("dmi")

@pytest.fixture
def lint(request: FixtureRequest) -> Lint:
    marker = request.node.get_closest_marker("lint")
    title = marker.args[0] if marker else request.node.name
    return Lint(title)

@pytest.fixture(scope="session")
def dme() -> DME:
    return DME.from_file(get_repo_root() / "paradise.dme", parse_procs=True)

# Fuck it, send us to the repo root I guess.
# We don't use absolute paths because they look bad in logging, only the local repository path should be shown when printing.
# Using relative string paths doesn't work outside of the base of the repository. This is undesirable.
# Absolute and relative pathlib.Path() aren't perfect either, as ProcessPoolExecutor().map() can't pickle these paths. We stringify those paths to get around this.
# Also, PurePath doesn't seem to be pickle-able either.
# I also hear you ask, why not make the filename relative in lint.error()?
# Well, any filenames that are referenced by error messages will still be printed as absolute, even if the fileerror is printed correctly.
# e.g. "test/ooc.dm: has the same file name as C:/Users/Myself/Documents/Paradise/otherfolder/ooc.dm"
# I believe this is the best solution for now. It will probably result in a un-debuggable mess in the future.
os.chdir(get_repo_root())
