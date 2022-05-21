# Python script for SQL validation
# For Python 3!, not 2
# Basically, this script reads through every SQL update file and prepares it for testing against the SQL server
# This ensures that SQL files have correct syntax, and are not malformed
# -AA07
import glob, os, shutil, stat
os.chdir("SQL/updates")
sqlFiles = glob.glob("*.sql")
sqlFiles += glob.glob("*.py")
orderedSqlFiles = []
# These need to be ordered properly, so begin awful hacky code
for fileName in sqlFiles:
    prev = fileName.split("-")[0]
    orderedSqlFiles.append(int(prev))

orderedSqlFiles = sorted(orderedSqlFiles)

for index in orderedSqlFiles:
    # AND YES I KNOW THIS IS SNOWFLAKEY AS HELL, BUT IT MUST BE DONE FOR PROPER CI
    if index in [16, 17, 31]:
        orderedSqlFiles[index] = "{}-{}.py".format(index, index + 1)
    else:
        orderedSqlFiles[index] = "{}-{}.sql".format(index, index + 1)

print("Found {} SQL update files to validate".format(len(orderedSqlFiles)))

# FROM THIS POINT ON, DO NOT SORT THAT LIST
# Go back up two directories
os.chdir("../../")

# Delete the testing directory IF it exists.
# This is what I mean by python being picky
if os.path.exists("tools/ci/sql_tmp") and os.path.isdir("tools/ci/sql_tmp"):
    shutil.rmtree("tools/ci/sql_tmp")

# Now make the dir
os.mkdir("tools/ci/sql_tmp")

# These lines will be used to generate a file which runs all the SQL scripts
# First we test from schema 0 all the way up to latest
# Then the prefixed schema
# Then the main schema, which the server will use
scriptLines = [
    "#!/bin/bash\n",
    "set -euo pipefail\n"
    "python3 -m pip install setuptools\n" # Yes I know you can PIP multiple things but they need to happen in this order
    "python3 -m pip install mysql-connector-python\n"
    "mysql -u root -proot < tools/ci/sql_v0.sql\n"
]

# And write the files and tell them to be used
for file in orderedSqlFiles:
    if file.endswith(".py"):
        # Begin snowflakery
        if file == "16-17.py":
            scriptLines.append("python3 SQL/updates/{} 127.0.0.1 root root paradise_gamedb feedback round\n".format(file))
        elif file == "17-18.py":
            scriptLines.append("python3 SQL/updates/{} 127.0.0.1 root root paradise_gamedb feedback feedback_2\n".format(file))
        elif file == "31-32.py":
            scriptLines.append("python3 SQL/updates/{} 127.0.0.1 root root paradise_gamedb\n".format(file))
        else:
            print("ERROR: CI failed due to invalid python file in SQL/updates")
            exit(1)
    else:
        inFile = open("SQL/updates/{}".format(file), "r")
        fileLines = inFile.readlines()
        inFile.close()
        # Add in a line which tells it to use the paradise DB
        fileLines.insert(0, "USE `paradise_gamedb`;\n")

        # Write new files to be used by the testing script
        outFile = open("tools/ci/sql_tmp/{}".format(file), "w+")
        outFile.writelines(fileLines)
        outFile.close()

        # Add a line to the script being made that tells it to use this SQL file
        scriptLines.append("mysql -u root -proot < tools/ci/sql_tmp/{}\n".format(file))

# Dump the DB to a file to do diff checking with
# We need the awful sed stuff here so that we can remove AUTO_INCREMENT saved values
scriptLines.append("mysqldump -d -u root -proot -p paradise_gamedb | sed 's/ AUTO_INCREMENT=[0-9]*\\b//' | sed 's/ COLLATE=utf8mb4_unicode_ci|utf8mb4_0900_ai_ci\\b//' > UPDATED_SCHEMA.sql\n")
scriptLines.append("mysql -u root -proot -e 'DROP DATABASE paradise_gamedb;'\n")
scriptLines.append("mysql -u root -proot < SQL/paradise_schema.sql\n")
scriptLines.append("mysqldump -d -u root -proot -p paradise_gamedb | sed 's/ AUTO_INCREMENT=[0-9]*\\b//' | sed 's/ COLLATE=utf8mb4_unicode_ci|utf8mb4_0900_ai_ci\\b//' > FRESH_SCHEMA.sql\n")

# Now diff. This should exit 1 if they are different
scriptLines.append("diff UPDATED_SCHEMA.sql FRESH_SCHEMA.sql\n")

outputScript = open("tools/ci/validate_sql.sh", "w+")
outputScript.writelines(scriptLines)
outputScript.close()

st = os.stat('tools/ci/validate_sql.sh')
os.chmod('tools/ci/validate_sql.sh', st.st_mode | stat.S_IEXEC)
print("SQL validation script written successfully")
