from enum import StrEnum
import os
import pytest
from avulto.ast import SourceLoc
from pathlib import Path
from typing import Optional

class Color(StrEnum):
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    BLUE = "\033[0;34m"
    NO_COLOR = "\033[0m"

GITHUB_ACTIONS = os.getenv("GITHUB_ACTIONS") == "true"

@pytest.fixture(autouse=True)
def reset_error_reporters():
    yield

    for reporter in ErrorReporter.instances:
        reporter.END_TEST()

class ErrorReporter:
    instances: list[ErrorReporter] = []

    def __init__(self, title: str):
        self.title = title
        self.total_errors = 0
        self.instances.append(self)

    def _github_format(
        self,
        message: str,
        filename: Optional[str | Path] = None,
        line_number: Optional[int] = None,
    ) -> str:
        location = ""
        prefix = ""

        if filename and line_number:
            location = f" file={filename},line={line_number}"
            prefix = f"{filename}:{line_number}:"

        elif filename:
            location = f" file={filename}"
            prefix = f"{filename}: "

        return f"::error{location},title={self.title}::{prefix}{message}"

    def _plain_format(
        self,
        message: str,
        filename: Optional[str | Path] = None,
        line_number: Optional[int] = None,
    ) -> str:

        if filename == None:
            return f"ERROR: {message}"

        if line_number == None:
            return f"{filename}: {message}"

        return f"{filename}:{line_number}: {message}"

    def format(
        self,
        message: str,
        filename: Optional[str | Path] = None,
        line_number: Optional[int] = None,
    ) -> str:
        # Color the message so it looks good
        message = f"{Color.RED}{message}{Color.NO_COLOR}"
        self.total_errors += 1

        if GITHUB_ACTIONS:
            return self._github_format(message, filename, line_number)
        return self._plain_format(message, filename, line_number)

    def print(
        self,
        message: str,
        filename: Optional[str | Path] = None,
        line_number: Optional[int] = None,
    ) -> None:
        print(self.format(message, filename, line_number))

    def print_source_loc(self, message: str, source_loc: SourceLoc) -> None:
        self.print(message, source_loc.file_path, source_loc.line)

    # If this function or any of EXIT_message functions are not called,
    # errors will probably not be printed.
    # I haven't found a great solution for this yet that isn't jank.
    def END_TEST(self, message: Optional[str] = None):
        errors = self.total_errors
        self.total_errors = 0
        if errors > 0:
            if message == None:
                message = f"This test had {errors} failures"
            EXIT_message(message)


def EXIT_message(message: str) -> None:
    pytest.fail(message, pytrace=False)

def EXIT_message_list(messages: list[str]) -> None:
    pytest.fail("\n".join(messages), pytrace=False)
