# Converts all existing loadout `gear` listings in the `characters` table from their 'display_name's to their typepaths.
# To use, run `python loadout_converter.py {address} {username} {password} {database}` in the console, with the {} arguments being your SQL database information.

# Note: This must ONLY be run once, and ONLY if your loadout records are using the old system.

import re, mysql.connector, argparse, json, time

parser = argparse.ArgumentParser()
parser.add_argument("address", help="SQL server address (Use 127.0.0.1 for the current computer)")
parser.add_argument("username", help="SQL login username")
parser.add_argument("password", help="SQL login password")
parser.add_argument("database", help="Database name (Default: paradise_gamedb)")

args = parser.parse_args()
db = mysql.connector.connect(host=args.address, user=args.username, password=args.password, database=args.database)
cursor = db.cursor()

startwatch = time.time()

with open('loadout_converter.json') as json_file:
	json = json.load(json_file)
	# Format for both variables is (Key: `display_name`, Value: typepath)
	standard_replacements = json["standard"]
	special_replacements = json["special"]

cursor.execute("SELECT id, gear FROM characters WHERE gear != \"\";")
temp = cursor.fetchall()

# Convert the rows into a dictionary. (Key: `id`, Value: `gear`)
print("----------")
loadouts = {}
for i in temp:
	row = {i[0]: i[1]}
	loadouts.update(row)
print("Cached gear listings.")

# Replace all `display_name`s in the list with their typepaths.
print("Converting gear listings...")
for item in loadouts:
	for name in standard_replacements:
		loadouts[item] = loadouts[item].replace(name, f"\"{standard_replacements[name]}\"")

	for thing in special_replacements:
		loadouts[item] = re.sub(fr'(^|&)(?:{thing})($|&)', fr'\1"{special_replacements[thing]}"\2', loadouts[item])
		# This is horrible, but as far as I can tell there's no other way of doing it.
		# If the subtype is converted first and then the parent type, you get "/datum/gear/accessory//datum/gear/accessory/scarf/christmas".
		# If the parent type is converted first and then the subtype, you get "/datum/gear/accessory/scarf%2c+christmas".
		# This regex ensures that either the start of the string, the end of the string, or an & character are surrounding `thing`, so no false matches.

	# Convert to JSON formatting.
	loadouts[item] = loadouts[item].replace("&", ",")
	loadouts[item] = "[" + loadouts[item] + "]"
print("Converted {} gear listings.".format(len(loadouts)))

# Update the database.
print("Updating database entries...")
for id in loadouts:
	gear = loadouts[id]
	stmt = "UPDATE characters SET gear = %s WHERE id = %s;"
	cursor.execute(stmt, (gear, id))
db.commit()

stopwatch = time.time()
print("Database updated in {} seconds!".format(round(stopwatch - startwatch)))
