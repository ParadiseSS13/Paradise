# Script to generate changelog from commit tree
# Listen up.
# In order to run this script on Windows, you need to make sure you have Python **3** installed. Tested on 3.8.2
# It won't work on 2.7 at all.

# To run this, supply the following args in a command shell
# python 30-31.py address username password database table_old table_new
# Example:
# python 30-31.py localhost paradise ban_old ban

# !/usr/bin/env python3


from git import Repo
from datetime import date
import yaml

validPrefixes = [
    "add",
    "admin",
    "balance",
    "bugfix",
    "code_imp",
    "config",
    "del",
    "expansion",
    "experiment",
    "image",
    "imageadd",
    "imagedel",
    "qol",
    "refactor",
    "rscadd",
    "rscdel",
    "server",
    "sound",
    "soundadd",
    "sounddel",
    "spellcheck",
    "tweak",
    "unknown",
    "wip",
]

today = date.today()
repo = Repo()
commitsSet = set()


def add_commits(commit):
    if date.fromtimestamp(commit.committed_date).month >= today.month - 1:
        if not commit.message.startswith("Automatic changelog generation"):
            commitsSet.add(commit)
        for parent in commit.parents:
            add_commits(parent)


def commit_key(c):
    return c.committed_date


add_commits(repo.head.commit)
commitsByDate = dict()
commitsSorted = list(commitsSet)
commitsSorted.sort(key=commit_key)

for i in commitsSorted:
    commit_time = date.fromtimestamp(i.committed_date)
    commit_year_mount = commit_time.strftime("%Y-%m")
    commit_year_mount_day = commit_time.strftime("%Y-%m-%d").format()
    if commit_year_mount not in commitsByDate:
        commitsByDate[commit_year_mount] = dict()
    if commit_year_mount_day not in commitsByDate[commit_year_mount]:
        commitsByDate[commit_year_mount][commit_year_mount_day] = dict()

    if i.author.name not in commitsByDate[commit_year_mount][commit_year_mount_day]:
        commitsByDate[commit_year_mount][commit_year_mount_day][i.author.name] = list()

    message = i.message.splitlines()[0]
    split = message.split(':', 1)
    prefix = ""
    change = ""
    if len(split) > 1:
        prefix = split[0].lower()
        change = split[1]
        if prefix.startswith("fix") or prefix == "hotfix":
            prefix = "bugfix"
        elif prefix == "buff":
            prefix = "tweak"
        elif prefix == "feat":
            prefix = "add"
        elif prefix.startswith("ref"):
            prefix = "refactor"
        elif prefix.startswith("revert"):
            prefix = "del"
        elif prefix not in validPrefixes:
            prefix = "unknown"
    else:
        prefix = "server"
        change = split[0]

    commitsByDate[commit_year_mount][commit_year_mount_day][i.author.name].append({prefix: change.strip()})

for i in commitsByDate:
    with open("html/changelogs/archive/{}.yml".format(i), 'w', encoding='utf-8') as f:
        yaml.dump(commitsByDate[i], f, default_flow_style=False, allow_unicode=True)
