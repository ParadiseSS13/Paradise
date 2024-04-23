"""
DO NOT MANUALLY RUN THIS SCRIPT.
---------------------------------

Expected envrionmental variables:
-----------------------------------
GITHUB_REPOSITORY: Github action variable representing the active repo (Action provided)
BOT_TOKEN: A repository account token, this will allow the action to push the changes (Action provided)
GITHUB_EVENT_PATH: path to JSON file containing the event info (Action provided)
"""
import os
import re
import copy
from pathlib import Path
from ruamel.yaml import YAML
from github import Github
import json

DISCORD_EMBED_DESCRIPTION_LIMIT = 4096

CL_BODY = re.compile(r"(:cl:|🆑)[ \t]*(?P<author>.+?)?\s*\n(?P<content>(.|\n)*?)\n/(:cl:|🆑)", re.MULTILINE)
CL_SPLIT = re.compile(r"\s*((?P<tag>\w+)\s*:)?\s*(?P<message>.*)")

DISCORD_TAG_EMOJI = {
    "soundadd": ":notes:",
    "sounddel": ":mute:",
    "imageadd": ":frame_photo:",
    "imagedel": ":scissors:",
    "codeadd": ":sparkles:",
    "codedel": ":wastebasket:",
    "tweak": ":screwdriver:",
    "fix": ":tools:",
    "wip": ":construction_site:",
    "spellcheck": ":pencil:",
    "experiment": ":microscope:"
}


def build_changelog(pr: dict) -> dict:
    changelog = parse_changelog(pr.body)
    changelog["author"] = changelog["author"] or pr.user.login
    return changelog


def emojify_changelog(changelog: dict):
    changelog_copy = copy.deepcopy(changelog)
    for change in changelog_copy["changes"]:
        if change["tag"] in DISCORD_TAG_EMOJI:
            change["tag"] = DISCORD_TAG_EMOJI[change["tag"]]
        else:
            raise Exception(f"Invalid tag for emoji: {change}")
    return changelog_copy


def validate_changelog(changelog: dict):
    if not changelog:
        raise Exception("No changelog.")
    if not changelog["author"]:
        raise Exception("The changelog has no author.")
    if len(changelog["changes"]) == 0:
        raise Exception("No changes found in the changelog. Use special label if changelog is not expected.")
    message = "\n".join(map(lambda change: f"{change['tag']} {change['message']}", changelog["changes"]))
    if len(message) > DISCORD_EMBED_DESCRIPTION_LIMIT:
        raise Exception(f"The changelog exceeds the length limit ({DISCORD_EMBED_DESCRIPTION_LIMIT}). Shorten it.")


def parse_changelog(message: str) -> dict:
    with open(Path.cwd().joinpath("tags.yml")) as file:
        yaml = YAML(typ = 'safe', pure = True)
        tags_config = yaml.load(file)
    cl_parse_result = CL_BODY.search(message)
    if cl_parse_result is None:
        raise Exception("Failed to parse the changelog. Check changelog format.")
    cl_changes = []
    for cl_line in cl_parse_result.group("content").splitlines():
        if not cl_line:
            continue
        change_parse_result = CL_SPLIT.search(cl_line)
        if not change_parse_result:
            raise Exception(f"Invalid change: '{cl_line}'")
        tag = change_parse_result["tag"]
        message = change_parse_result["message"]
        if tag and tag not in tags_config['tags'].keys():
            raise Exception(f"Invalid tag: '{cl_line}'. Valid tags: {', '.join(tags_config['tags'].keys())}")
        if not message:
            raise Exception(f"No message for change: '{cl_line}'")
        if message in list(tags_config['defaults'].values()): # Check to see if the tags are associated with something that isn't the default text
            raise Exception(f"Don't use default message for change: '{cl_line}'")
        if tag:
            cl_changes.append({
                "tag": tags_config['tags'][tag],
                "message": message
            })
        # Append line without tag to the previous change
        else:
            if len(cl_changes):
                prev_change = cl_changes[-1]
                prev_change["message"] += f" {change_parse_result['message']}"
            else:
                raise Exception(f"Change with no tag: {cl_line}")

    if len(cl_changes) == 0:
        raise Exception("No changes found in the changelog. Use special label if changelog is not expected.")
    return {
        "author": str.strip(cl_parse_result.group("author") or "") or None,  # I want this to be None, not empty
        "changes": cl_changes
    }


# Blessed is the GoOnStAtIoN birb ZeWaKa for thinking of this first
repo = os.getenv("GITHUB_REPOSITORY")
token = os.getenv("BOT_TOKEN")
event_path = os.getenv("GITHUB_EVENT_PATH")

with open(event_path, 'r') as f:
    event_data = json.load(f)

git = Github(token)
repo = git.get_repo(repo)
pr = repo.get_pull(event_data['number'])

pr_body = pr.body or ""
pr_author = pr.user.login
pr_labels = pr.labels

CL_INVALID = ":scroll: CL невалиден"
CL_VALID = ":scroll: CL валиден"
CL_NOT_NEEDED = ":scroll: CL не требуется"

pr_is_mirror = pr.title.startswith("[MIRROR]")

has_valid_label = False
has_invalid_label = False
cl_required = True
for label in pr_labels:
    print("Found label: ", label.name)
    if label.name == CL_NOT_NEEDED:
        print("No CL needed!")
        cl_required = False
    if label.name == CL_VALID:
        has_valid_label = True
    if label.name == CL_INVALID:
        has_invalid_label = True

if pr_is_mirror:
    cl_required = False

if not cl_required:
    # remove invalid, remove valid
    if has_invalid_label:
        pr.remove_from_labels(CL_INVALID)
    if has_valid_label:
        pr.remove_from_labels(CL_VALID)
    exit(0)

try:
    cl = build_changelog(pr)
    cl_emoji = emojify_changelog(cl)
    cl_emoji["author"] = cl_emoji["author"] or pr_author
    validate_changelog(cl_emoji)
except Exception as e:
    print("Changelog parsing error:")
    print(e)

    # add invalid, remove valid
    if not has_invalid_label:
        pr.add_to_labels(CL_INVALID)
    if has_valid_label:
        pr.remove_from_labels(CL_VALID)
    exit(1)

# remove invalid, add valid
if has_invalid_label:
    pr.remove_from_labels(CL_INVALID)
if not has_valid_label:
    pr.add_to_labels(CL_VALID)
print("Changelog is valid.")
