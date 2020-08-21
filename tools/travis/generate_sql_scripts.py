# Python script for SQL validation
# For Python 3!, not 2
# Basically, this script reads through every SQL update file and prepares it for testing against the SQL server
# This ensures that SQL files have correct syntax, and are not malformed
# -AA07
import glob, os, shutil, stat
os.chdir("SQL/updates")
sqlFiles = glob.glob("*.sql")
orderedSqlFiles = []
# These need to be ordered properly, so begin awful hacky code
for fileName in sqlFiles:
    prev = fileName.split("-")[0]
    orderedSqlFiles.append(int(prev))

orderedSqlFiles = sorted(orderedSqlFiles)

for index in orderedSqlFiles:
    # Yes I know half these casts are probably not necassary, but python is very picky
    orderedSqlFiles[index] = str(index) + "-" + (str(int(index)+1)) + ".sql"

print("Found " + str(len(orderedSqlFiles)) + " SQL update files to validate")

# FROM THIS POINT ON, DO NOT SORT THAT LIST
# Go back up two directories
os.chdir("../../")

# Delete the testing directory IF it exists.
# This is what I mean by python being picky
if os.path.exists("tools/travis/sql_tmp") and os.path.isdir("tools/travis/sql_tmp"):
    shutil.rmtree("tools/travis/sql_tmp")

# Now make the dir
os.mkdir("tools/travis/sql_tmp")

# These lines will be used to generate a file which runs all the SQL scripts
# First we test from schema 0 all the way up to latest
# Then the prefixed schema
# Then the main schema, which the server will use
scriptLines = [
    "#!/bin/bash\n",
    "set -euo pipefail\n"
    "mysql -u root < tools/travis/sql_v0.sql\n"
]

# And write the files and tell them to be used
for file in orderedSqlFiles:
    inFile = open("SQL/updates/" + file, "r")
    fileLines = inFile.readlines()
    inFile.close()
    # Add in a line which tells it to use the feedback DB
    fileLines.insert(0, "USE `feedback`;\n")

    # Write new files to be used by the testing script
    outFile = open("tools/travis/sql_tmp/" + file, "w+")
    outFile.writelines(fileLines)
    outFile.close()

    # Add a line to the script being made that tells it to use this SQL file
    scriptLines.append("mysql -u root < tools/travis/sql_tmp/" + str(file) + "\n")

scriptLines.append("mysql -u root -e 'DROP DATABASE feedback;'\n")
scriptLines.append("mysql -u root < SQL/paradise_schema_prefixed.sql\n")
scriptLines.append("mysql -u root -e 'DROP DATABASE feedback;'\n")
scriptLines.append("mysql -u root < SQL/paradise_schema.sql\n")
scriptLines.append("mysql -u root -e 'GRANT ALL on feedback.* TO `travis_sql`@`127.0.0.1` IDENTIFIED BY \"not_a_strong_password\";'\n")

outputScript = open("tools/travis/validate_sql.sh", "w+")
outputScript.writelines(scriptLines)
outputScript.close()

st = os.stat('tools/travis/validate_sql.sh')
os.chmod('tools/travis/validate_sql.sh', st.st_mode | stat.S_IEXEC)
print("SQL validation script written successfully")
