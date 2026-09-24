from dataclasses import dataclass, field
from pathlib import Path
import os
from enum import StrEnum

import pytest

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
    errors: list[LintError] = field(default_factory=list)

    def error(self, msg: str, file: str | Path | None = None, line: int | None = None) -> None:
        self.errors.append(LintError(msg, str(file) if file is not None else None, line, self.title))


# If we're in a GitHub Actions context, write annotations alongside the default
# failure messages
def pytest_terminal_summary(terminalreporter):
    if not GITHUB_ACTIONS:
        return

    for rep in terminalreporter.stats.get("failed", []):
        for name, errs in rep.user_properties:
            if name == "lint_errors":
                for lint_error in errs:
                    terminalreporter.write_line(lint_error.to_github_annotation())


@pytest.hookimpl(wrapper=True)
def pytest_runtest_call(item):
    result = yield
    lint = item.funcargs.get("lint")
    if lint and lint.errors:
        item.user_properties.append(("lint_errors", lint.errors))
        # TODO: Don't use ansi color codes if pytest has colors set to false
        pytest.fail("\n".join(e.to_ansi_formatted() for e in lint.errors), pytrace=False)
    return result


@pytest.fixture
def lint(request) -> Lint:
    marker = request.node.get_closest_marker("lint")
    title = marker.args[0] if marker else request.node.name
    return Lint(title)
