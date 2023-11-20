import git
import json
import re
import os
BUILD_PATH = "./"

allowPathsRegexp = re.compile('^code/.*')

repo = git.Repo(BUILD_PATH)
tree = repo.head.commit.tree
if not tree:
    print("No changes")
    exit()
diff = repo.git.diff(tree)
if not diff:
    print("No changes")
    exit()

# Оставляем только стоки, где строки начинаются с "+", "-", "---"
diff = [line for line in diff.split("\n") if line[0] in "+-" and not line.startswith("+++")]

# Собираем в структуру вида:
# {
#   "file": "player.dm",
#   "origin": ["Test", "Test2"],
#   "replace": ["Тест", "Тест2"]
# }
prepare = []
lastFile = ''
for line in diff:
    if line.startswith("---"):
        lastFile = line[6:]
        prepare.append({"file": lastFile, "origin": [], "replace": []})
    elif line.startswith("-"):
        prepare[-1]['origin'].append(line[1:])
    elif line.startswith("+"):
        prepare[-1]['replace'].append(line[1:])

# Фильтруем структуру: Оставляем только разрешенные файлы
filtered = []
for item in prepare:
    if not allowPathsRegexp.match(item['file']):
        continue
    filtered.append(item)

# Собираем в структуру для хранения в файле:
# {
#   "files": [
#       {
#           "path": "player.dm",
#           "replaces": [
#               {"original": "Test", "replace": "Тест"},
#               {"original": "Test2", "replace": "Тест2"}
#           ]
#       }
#   ]
# }
jsonStructure = {"files": []}
for item in filtered:
    originLen = len(item["origin"])
    replaceLen = len(item["replace"])

    if originLen != replaceLen:
        print("Changes not equals")
        print(item)
        exit(1)

    file = {"path": item["file"], "replaces": []}

    for i in range(originLen):
        file["replaces"].append({"original": item["origin"][i], "replace": item["replace"][i]})

    jsonStructure["files"].append(file)

jsonFilePath = os.path.dirname(os.path.realpath(__file__)) + '/ss220replace.json'

# Добавляем новые элементы к текущим в файле
fullTranslation = json.load(open(jsonFilePath, encoding='utf-8'))
for file in jsonStructure['files']:
    fullTranslation["files"].append(file)

with open(jsonFilePath, 'w+', encoding='utf-8') as f:
    json.dump(fullTranslation, f, ensure_ascii=False, indent=2)

print(f"Added translation for {len(jsonStructure['files'])} files.")
