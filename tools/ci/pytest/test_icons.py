from collections import defaultdict
from pathlib import Path
from typing import cast

from avulto import DMI, IconState
from conftest import Lint


def check_duplicate_names(dmi: DMI) -> list[str]:
    states: set[tuple[str, bool]] = set()
    failures: list[str] = []
    for state in dmi.states:
        # TODO, remove this once avulto has complete type casting
        state: IconState = cast(IconState, state)
        # Movement states have the same name as their non-movement counterparts
        if (state.name, state.movement) in states:
            failures.append(f"duplicate state name `{state.name}`")
        states.add((state.name, state.movement))
    return failures

def check_conflicted(dmi: DMI) -> list[str]:
    failures: list[str] = []
    for state in dmi.state_names():
        if '!CONFLICT!' in state:
            failures.append(f"conflicted state {state}")
    return failures

ICON_CHECKS = [
    check_duplicate_names,
    check_conflicted,
]

def test_icons(lint: Lint, dmi_files: list[Path]):
    findings: dict[Path, list[str]] = defaultdict(list)

    for dmi_path in dmi_files:
        dmi = DMI.from_file(dmi_path)
        for check in ICON_CHECKS:
            if failures := check(dmi):
                findings[dmi_path].extend(failures)

    if findings:
        for filename in sorted(findings.keys()):
            failures = findings[filename]
            for failure in sorted(failures):
                lint.error(failure, filename)

