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
    # Yes I know half of the casts below this are probably not necassary, but python is very picky
    # AND YES I KNOW THIS IS SNOWFLAKEY AS HELL, BUT IT MUST BE DONE FOR PROPER CI
    if index in [16, 17]:
        orderedSqlFiles[index] = str(index) + "-" + (str(int(index)+1)) + ".py"
    else:
        orderedSqlFiles[index] = str(index) + "-" + (str(int(index)+1)) + ".sql"

print("Found " + str(len(orderedSqlFiles)) + " SQL update files to validate")

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
    "python3 -m pip install mysql-connector\n"
    "mysql -u root -proot < tools/ci/sql_v0.sql\n"
]

# And write the files and tell them to be used
for file in orderedSqlFiles:
    if file.endswith(".py"):
        # Begin snowflakery
        if file == "16-17.py":
            scriptLines.append("python3 SQL/updates/" + str(file) + " 127.0.0.1 root root feedback feedback round\n")
        elif file == "17-18.py":
            scriptLines.append("python3 SQL/updates/" + str(file) + " 127.0.0.1 root root feedback feedback feedback_2\n")
        else:
            print("ERROR: CI failed due to invalid python file in SQL/updates")
            exit(1)
    else:
        inFile = open("SQL/updates/" + file, "r")
        fileLines = inFile.readlines()
        inFile.close()
        # Add in a line which tells it to use the feedback DB
        fileLines.insert(0, "USE `feedback`;\n")

        # Write new files to be used by the testing script
        outFile = open("tools/ci/sql_tmp/" + file, "w+")
        outFile.writelines(fileLines)
        outFile.close()

        # Add a line to the script being made that tells it to use this SQL file
        scriptLines.append("mysql -u root -proot < tools/ci/sql_tmp/" + str(file) + "\n")

scriptLines.append("mysql -u root -proot -e 'DROP DATABASE feedback;'\n")
scriptLines.append("mysql -u root -proot < SQL/paradise_schema_prefixed.sql\n")
scriptLines.append("mysql -u root -proot -e 'DROP DATABASE feedback;'\n")
scriptLines.append("mysql -u root -proot < SQL/paradise_schema.sql\n")
scriptLines.append("mysql -u root -proot -e 'GRANT ALL on feedback.* TO `ci_sql`@`127.0.0.1` IDENTIFIED BY \"not_a_strong_password\";'\n")

outputScript = open("tools/ci/validate_sql.sh", "w+")
outputScript.writelines(scriptLines)
outputScript.close()

st = os.stat('tools/ci/validate_sql.sh')
os.chmod('tools/ci/validate_sql.sh', st.st_mode | stat.S_IEXEC)
print("SQL validation script written successfully")
