import git
import json
BUILD_PATH = "./"


repo = git.Repo(BUILD_PATH)
tree = repo.head.commit.tree
if not tree:
    print("No changes")
    exit()
diff = repo.git.diff(tree)
if not diff:
    print("No changes")
    exit()
diff = [line for line in diff.split("\n") if line[0] in "+-" and not line.startswith("+++")]

translation = {"files": []}

lastfile = ''
lastaction = ''
for line in diff:
    if line.startswith("---"):
        lastfile = line[6:]
        lastaction = '---'
        translation["files"].append({"path": lastfile, "replaces": []})
    elif line.startswith("-"):
        if lastaction == "---" or lastaction == "+":
            translation["files"][-1]["replaces"].append({"original": line[1:], "replace": ""})
        elif lastaction == "-":
            translation["files"][-1]["replaces"][-1]["original"]+=f"\n{line[1:]}"
        lastaction = "-"
    elif line.startswith("+"):
        if lastaction == "-":
            translation["files"][-1]["replaces"][-1]["replace"] = line[1:]
        elif lastaction == "+":
            translation["files"][-1]["replaces"][-1]["replace"] += f"\n{line[1:]}"
        lastaction = "+"

with open('ss220replace.json', 'w+', encoding='utf-8') as f:
    json.dump(translation, f, ensure_ascii=False, indent=2)
print(f"Added translation for {len(translation['files'])} files.")
