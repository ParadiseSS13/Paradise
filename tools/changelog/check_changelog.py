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
from pathlib import Path
from ruamel.yaml import YAML
from github import Github
import json

CL_BODY = re.compile(r"(:cl:|🆑)(.+)?\n((.|\n|)+?)\n\/(:cl:|🆑)", re.MULTILINE)
CL_SPLIT = re.compile(r"(^\w+):\s+(\w.+)", re.MULTILINE)

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

write_cl = {}
try:
    cl = CL_BODY.search(pr_body)
    cl_list = CL_SPLIT.findall(cl.group(3))
except AttributeError:
    print("No CL found!")

    if not cl_required:
        # remove invalid, remove valid
        if has_invalid_label:
            pr.remove_from_labels(CL_INVALID)
        if has_valid_label:
            pr.remove_from_labels(CL_VALID)
        exit(0)

    # add invalid, remove valid
    if not has_invalid_label:
        pr.add_to_labels(CL_INVALID)
    if has_valid_label:
        pr.remove_from_labels(CL_VALID)
    exit(0)


if cl.group(2) is not None:
    write_cl['author'] = cl.group(2).strip()
else:
    write_cl['author'] = pr_author

if not write_cl['author']:
    print("There are spaces or tabs instead of author username")

with open(Path.cwd().joinpath("tags.yml")) as file:
    yaml = YAML(typ='safe',pure=True)
    tags = yaml.load(file)

write_cl['changes'] = []

has_invalid_tag = False
for k, v in cl_list:
    if k in tags['tags'].keys(): # Check to see if there are any valid tags, as determined by tags.yml
        v = v.rstrip()
        if v not in list(tags['defaults'].values()): # Check to see if the tags are associated with something that isn't the default text
            write_cl['changes'].append({tags['tags'][k]: v})
    else:
        print(f"Tag {k} is invalid!")
        has_invalid_tag = True

if has_invalid_tag:
    print("CL has invalid tags!")
    print("Valid tags are:")
    print(*tags['tags'].keys(), sep=", ")

if write_cl['changes']:
    print("CL OK!")
    # remove invalid, add valid
    if has_invalid_label:
        pr.remove_from_labels(CL_INVALID)
    if not has_valid_label:
        pr.add_to_labels(CL_VALID)
else:
    print("No CL changes detected!")
    # add invalid, remove valid
    if not has_invalid_label:
        pr.add_to_labels(CL_INVALID)
    if has_valid_label:
        pr.remove_from_labels(CL_VALID)

exit(0)
