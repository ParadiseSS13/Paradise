import enum
import os
import re
import subprocess
import time
import typing

from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, Future, as_completed
from pathlib import Path
from re import Pattern
from subprocess import CompletedProcess

from github import Github
from github.PaginatedList import PaginatedList
from github.PullRequest import PullRequest
from github.Repository import Repository
from openai import OpenAI
from openai.types.chat import ChatCompletion

import changelog_utils


class UpstreamLabel(str, enum.Enum):
    CONFIG_CHANGE = "Configuration Change"
    SQL_CHANGE = "SQL Change"
    WIKI_CHANGE = "Requires Wiki Update"


class DownstreamLabel(str, enum.Enum):
    WIKI_CHANGE = ":page_with_curl: Требуется изменение WIKI"


class Change(typing.TypedDict):
    tag: str
    message: str
    translated_message: typing.NotRequired[str]
    pull: PullRequest


class PullDetails(typing.TypedDict):
    changelog: typing.Dict[int, list[Change]]
    merge_order: list[int]
    config_changes: list[PullRequest]
    sql_changes: list[PullRequest]
    wiki_changes: list[PullRequest]


LABEL_BLOCK_STYLE = {
    UpstreamLabel.CONFIG_CHANGE: "IMPORTANT",
    UpstreamLabel.SQL_CHANGE: "IMPORTANT",
    UpstreamLabel.WIKI_CHANGE: "NOTE",
}


def check_env():
    """Check if the required environment variables are set."""
    required_vars = [
        "GITHUB_TOKEN",
        "TARGET_REPO",
        "TARGET_BRANCH",
        "UPSTREAM_REPO",
        "UPSTREAM_BRANCH",
        "MERGE_BRANCH"
    ]
    if TRANSLATE_CHANGES:
        required_vars.append("OPENAI_API_KEY")
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    if missing_vars:
        raise EnvironmentError(f"Missing required environment variables: {', '.join(missing_vars)}")


# Environment variables
TRANSLATE_CHANGES = os.getenv("TRANSLATE_CHANGES", "False").lower() in ("true", "yes", "1")
CHANGELOG_AUTHOR = os.getenv("CHANGELOG_AUTHOR", "")

check_env()
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
TARGET_REPO = os.getenv("TARGET_REPO")
TARGET_BRANCH = os.getenv("TARGET_BRANCH")
UPSTREAM_REPO = os.getenv("UPSTREAM_REPO")
UPSTREAM_BRANCH = os.getenv("UPSTREAM_BRANCH")
MERGE_BRANCH = os.getenv("MERGE_BRANCH")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")


def run_command(command: str) -> str:
    """Run a shell command and return its output."""
    try:
        result: CompletedProcess[str] = subprocess.run(command, shell=True, capture_output=True, text=True)
        result.check_returncode()
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {command}\nExit code: {e.returncode}\nOutput: {e.output}\nError: {e.stderr}")
        raise


def setup_repo():
    """Clone the repository and set up the upstream remote."""
    print(f"Cloning repository: {TARGET_REPO}")
    run_command(f"git clone https://x-access-token:{GITHUB_TOKEN}@github.com/{TARGET_REPO}.git repo")
    os.chdir("repo")
    run_command(f"git remote add upstream https://x-access-token:{GITHUB_TOKEN}@github.com/{UPSTREAM_REPO}.git")
    print(run_command(f"git remote -v"))


def update_merge_branch():
    """Update the merge branch with the latest changes from upstream."""
    print(f"Fetching branch {UPSTREAM_BRANCH} from upstream...")
    run_command(f"git fetch upstream {UPSTREAM_BRANCH}")
    run_command(f"git fetch origin")
    all_branches: list[str] = run_command("git branch -a").split()

    if f"remotes/origin/{MERGE_BRANCH}" not in all_branches:
        print(f"Branch '{MERGE_BRANCH}' does not exist. Creating it from upstream/{UPSTREAM_BRANCH}...")
        run_command(f"git checkout -b {MERGE_BRANCH} upstream/{UPSTREAM_BRANCH}")
        run_command(f"git push -u origin {MERGE_BRANCH}")
        return

    print(f"Resetting {MERGE_BRANCH} onto upstream/{UPSTREAM_BRANCH}...")
    run_command(f"git checkout {MERGE_BRANCH}")
    run_command(f"git reset --hard upstream/{UPSTREAM_BRANCH}")

    print("Pushing changes to origin...")
    run_command(f"git push origin {MERGE_BRANCH} --force")


def detect_commits() -> list[str]:
    """Detect commits from upstream not yet in downstream."""
    print("Detecting new commits from upstream...")
    commit_log: list[str] = run_command(f"git log {TARGET_BRANCH}..{MERGE_BRANCH} --pretty=format:'%h %s'").split("\n")
    commit_log.reverse()
    return commit_log


def fetch_pull(github: Github, pull_number: int) -> PullRequest | None:
    """Fetch the pull request from GitHub."""
    upstream_repo: Repository = github.get_repo(UPSTREAM_REPO)

    max_retries = 3
    for attempt in range(max_retries):
        try:
            return upstream_repo.get_pull(int(pull_number))
        except Exception as e:
            print(f"Error fetching PR #{pull_number}: {e}")
            if attempt + 1 < max_retries:
                time.sleep(2)
            else:
                return None


def build_details(github: Github, commit_log: list[str],
                  translate: typing.Optional[typing.Callable[[typing.Dict[int, list[Change]]], None]]) -> PullDetails:
    """Generate data from parsed commits."""
    print("Building details...")
    pull_number_pattern: Pattern[str] = re.compile("#(?P<id>\\d+)")
    details = PullDetails(
        changelog={},
        merge_order=[int(match.group("id")) for c in commit_log if (match := re.search(pull_number_pattern, c))],
        config_changes=[],
        sql_changes=[],
        wiki_changes=[]
    )
    pull_cache: dict[int, str] = {}

    with ThreadPoolExecutor() as executor:
        futures: dict[Future, int] = {}
        for commit in commit_log:
            match = re.search(pull_number_pattern, commit)
            if not match:
                print(f"Skipping {commit}")
                continue

            pull_number = int(match.group("id"))

            if pull_number in pull_cache:
                print(
                    f"WARNING: pull duplicate found.\n"
                    f"1: {pull_cache[pull_number]}\n"
                    f"2: {commit}"
                )
                print(f"Skipping {commit}")
                continue

            pull_cache[pull_number] = commit
            futures[executor.submit(fetch_pull, github, pull_number)] = pull_number

        for future in as_completed(futures):
            pull_number = futures[future]
            pull: PullRequest | None = future.result()

            if not pull:
                print(f"Pull {pull_number} was not fetched. Skipping.")
                continue

            process_pull(details, pull)

    if translate:
        translate(details["changelog"])

    return details


def process_pull(details: PullDetails, pull: PullRequest):
    """Handle fetched pull request data during details building."""
    pull_number: int = pull.number
    labels: list[str] = [label.name for label in pull.get_labels()]
    pull_changes: list[Change] = []
    try:
        for label in labels:
            if label == UpstreamLabel.CONFIG_CHANGE.value:
                details["config_changes"].append(pull)
            elif label == UpstreamLabel.SQL_CHANGE.value:
                details["sql_changes"].append(pull)
            elif label == UpstreamLabel.WIKI_CHANGE.value:
                details["wiki_changes"].append(pull)

        parsed = changelog_utils.parse_changelog(pull.body)
        if parsed and parsed["changes"]:
            for change in parsed["changes"]:
                pull_changes.append(Change(
                    tag=change["tag"],
                    message=change["message"],
                    pull=pull
                ))

        if pull_changes:
            details["changelog"][pull_number] = pull_changes
    except Exception as e:
        print(
            f"An error occurred while processing {pull.html_url}\n"
            f"Body: {pull.body}"
        )
        raise e


def translate_changelog(changelog: typing.Dict[int, list[Change]]):
    """Translate changelog using OpenAI API."""
    print("Translating changelog...")
    if not changelog:
        return

    changes: list[Change] = [change for changes in changelog.values() for change in changes]
    if not changes:
        return

    script_dir = Path(__file__).resolve().parent
    with open(script_dir.joinpath("translation_context.txt"), encoding="utf-8") as f:
        context = "\n".join(f.readlines()).strip()
    text = "\n".join([change["message"] for change in changes])

    client = OpenAI(
        base_url="https://models.inference.ai.azure.com",
        api_key=OPENAI_API_KEY,
    )
    response: ChatCompletion = client.chat.completions.create(
        messages=[
            {"role": "system", "content": context},
            {"role": "user", "content": text}
        ],
        temperature=1.0,
        top_p=1.0,
        model="gpt-4o",
    )
    translated_text: str | None = response.choices[0].message.content

    if not translated_text:
        print("WARNING: changelog translation failed!")
        print(response)
        return

    for change, translated_message in zip(changes, translated_text.split("\n"), strict=True):
        change["translated_message"] = translated_message


def silence_pull_url(pull_url: str) -> str:
    """Reformat HTTP URL with 'www' prefix to prevent pull request linking."""
    return re.sub("https?://", "www.", pull_url)


def prepare_pull_body(details: PullDetails) -> str:
    """Build new pull request body from the generated changelog."""
    pull_body: str = (
        f"This pull request merges upstream/{UPSTREAM_BRANCH}. "
        f"Resolve possible conflicts manually and make sure all the changes are applied correctly.\n"
    )

    if not details:
        return pull_body

    label_to_pulls: dict[UpstreamLabel, list[PullRequest]] = {
        UpstreamLabel.CONFIG_CHANGE: details["config_changes"],
        UpstreamLabel.SQL_CHANGE: details["sql_changes"],
        UpstreamLabel.WIKI_CHANGE: details["wiki_changes"]
    }
    for label, fetched_pulls in label_to_pulls.items():
        if not fetched_pulls:
            continue

        pull_body += (
            f"\n> [!{LABEL_BLOCK_STYLE[label]}]\n"
            f"> {label.value}:\n"
        )
        for fetched_pull in fetched_pulls:
            pull_body += f"> {silence_pull_url(fetched_pull.html_url)}\n"

    if not details["changelog"]:
        return pull_body

    pull_body += f"\n## Changelog\n"
    pull_body += f":cl: {CHANGELOG_AUTHOR}\n" if CHANGELOG_AUTHOR else ":cl:\n"
    for pull_number in details["merge_order"]:
        if pull_number not in details["changelog"]:
            continue
        for change in details["changelog"][pull_number]:
            tag: str = change["tag"]
            message: str = change["message"]
            translated_message: str | None = change.get("translated_message")
            pull_url: str = silence_pull_url(change["pull"].html_url)
            if translated_message:
                pull_body += f"{tag}: {translated_message} <!-- {message} ({pull_url}) -->\n"
            else:
                pull_body += f"{tag}: {message} <!-- ({pull_url}) -->\n"
    pull_body += "/:cl:\n"

    return pull_body


def create_pr(repo: Repository, details: PullDetails):
    """Create a pull request with the processed changelog."""
    pull_body: str = prepare_pull_body(details)
    print("Creating pull request...")

    # Create the pull request
    pull: PullRequest = repo.create_pull(
        title=f"Merge Upstream {datetime.today().strftime('%d.%m.%Y')}",
        body=pull_body,
        head=MERGE_BRANCH,
        base=TARGET_BRANCH
    )

    if details["wiki_changes"]:
        pull.add_to_labels(DownstreamLabel.WIKI_CHANGE)

    print("Pull request created successfully.")


def check_pull_exists(target_repo: Repository, base: str, head: str):
    """Check if the merge pull request already exist. In this case, fail the action."""
    print("Checking on existing pull request...")
    existing_pulls: PaginatedList[PullRequest] = target_repo.get_pulls(state="open", base=base, head=head)
    for pull in existing_pulls:
        print(f"Pull request already exists. {pull.html_url}")

    if existing_pulls.totalCount:
        exit(1)

if __name__ == "__main__":
    github = Github(GITHUB_TOKEN)
    target_repo: Repository = github.get_repo(TARGET_REPO)

    check_pull_exists(target_repo, TARGET_BRANCH, MERGE_BRANCH)
    setup_repo()

    update_merge_branch()
    commit_log: list[str] = detect_commits()

    if commit_log:
        details: PullDetails = build_details(github, commit_log, translate_changelog if TRANSLATE_CHANGES else None)
        create_pr(target_repo, details)
    else:
        print(f"No changes detected from {UPSTREAM_REPO}/{UPSTREAM_BRANCH}. Skipping pull request creation.")
