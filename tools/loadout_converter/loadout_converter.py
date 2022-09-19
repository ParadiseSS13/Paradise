# Converts all existing loadout `gear` listings in the `characters` table from their display_names to their typepaths.
# To use, run `python loadout_converter.py {address} {username} {password} {database}` in the console, with the {} arguments being your SQL database information.

# Note: This must ONLY be run once, and ONLY if your loadout records are using the old system.

import mysql.connector, argparse, json, time

parser = argparse.ArgumentParser()
parser.add_argument("address", help="SQL server address (Use 127.0.0.1 for the current computer)")
parser.add_argument("username", help="SQL login username")
parser.add_argument("password", help="SQL login password")
parser.add_argument("database", help="Database name (Default: paradise_gamedb)")

args = parser.parse_args()
db = mysql.connector.connect(host=args.address, user=args.username, password=args.password, database=args.database)
cursor = db.cursor()

startwatch = time.time()

try:
    with open('loadout_converter.json') as json_file:
        file_json = json.load(json_file)
        # Format for both replacement variables is (Key: `display_name`, Value: typepath)
        standard_replacements = file_json["standard"]
        special_replacements = file_json["special"]
except FileNotFoundError:
    print("Could not find the conversion file. Please make sure you're running the script from tools/loadout_converter/, not the repo root!")

cursor.execute("SELECT id, gear FROM characters WHERE gear != \"\";")
temp = cursor.fetchall()

# Convert the rows into a dictionary. (Key: `id`, Value: `gear`)
print("----------")
raw_loadouts = {}
converted_loadouts = {}
for i in temp:
    raw_loadouts[i[0]] = i[1]
print("Cached gear listings.")

# Replace all `display_name`s in the list with their typepaths.
print("Converting gear listings...")
for user_id in raw_loadouts:

    loadout_entry = raw_loadouts[user_id]
    # First split on &
    loadout_split = []
    if "&" in loadout_entry:
        loadout_split = loadout_entry.split("&")
    else:
        loadout_split.append(loadout_entry)

    # Now lets cleanup our entries
    for i in range(len(loadout_split)):
        if "=" in loadout_split[i]:
            loadout_split[i] = loadout_split[i].replace("=", "")

    new_loadout = []

    # Now we can get down to business
    for loadout_item in loadout_split:
        if loadout_item in standard_replacements:
            new_loadout.append(standard_replacements[loadout_item])

        if loadout_item in special_replacements:
            new_loadout.append(special_replacements[loadout_item])

    # Convert to JSON formatting.
    converted_loadouts[user_id] = json.dumps(new_loadout)

print("Converted {} gear listings.".format(len(raw_loadouts)))

# Update the database.
print("Updating database entries...")
for id in converted_loadouts:
    user_loadout = converted_loadouts[id]
    stmt = "UPDATE characters SET gear = %s WHERE id = %s;"
    cursor.execute(stmt, (user_loadout, id))
db.commit()

stopwatch = time.time()
print("Database updated in {} seconds!".format(round(stopwatch - startwatch)))
