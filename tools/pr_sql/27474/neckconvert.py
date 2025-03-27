import mysql.connector, argparse, json

parser = argparse.ArgumentParser()
parser.add_argument("address", help="MySQL server address (use localhost for the current computer)")
parser.add_argument("username", help="MySQL login username")
parser.add_argument("password", help="MySQL login password")
parser.add_argument("database", help="Database name")

args = parser.parse_args()
db = mysql.connector.connect(host=args.address, user=args.username, passwd=args.password, db=args.database)
cursor = db.cursor()
print("Connected to {}".format(args.database))

paths_to_nuke = ["/datum/gear/accessory/scarf", "/datum/gear/accessory/scarf/red", "/datum/gear/accessory/scarf/green", "/datum/gear/accessory/scarf/darkblue", "/datum/gear/accessory/scarf/purple", "/datum/gear/accessory/scarf/yellow", "/datum/gear/accessory/scarf/orange", "/datum/gear/accessory/scarf/lightblue", "/datum/gear/accessory/scarf/white", "/datum/gear/accessory/scarf/black", "/datum/gear/accessory/scarf/zebra", "/datum/gear/accessory/scarf/christmas", "/datum/gear/accessory/scarf/stripedred", "/datum/gear/accessory/scarf/stripedgreen", "/datum/gear/accessory/scarf/stripedblue", "/datum/gear/accessory/tieblue", "/datum/gear/accessory/tiered", "/datum/gear/accessory/tieblack", "/datum/gear/accessory/tiehorrible", "/datum/gear/accessory/stethoscope", "/datum/gear/accessory/locket/silver", "/datum/gear/accessory/locket", "/datum/gear/accessory/necklace/long", "/datum/gear/accessory/necklace", "/datum/gear/suit/mantle", "/datum/gear/suit/old_scarf", "/datum/gear/suit/regal_shawl", "/datum/gear/suit/mantle/job", "/datum/gear/suit/mantle/job/captain", "/datum/gear/suit/mantle/job/ce", "/datum/gear/suit/mantle/job/cmo", "/datum/gear/suit/mantle/job/hos", "/datum/gear/suit/mantle/job/hop", "/datum/gear/suit/mantle/job/rd"]

print("Loading data...")
load_qry = "SELECT id, gear FROM characters WHERE gear IS NOT NULL AND gear != ''" # fucking allowing empty strings instead of nullables
cursor.execute(load_qry)
res = cursor.fetchall()

to_replace = []

for row in res:
    row_id = row[0]
    loadout = json.loads(row[1])

    edited = False
    for entry in paths_to_nuke:
        if entry in loadout:
            if isinstance(loadout, dict): # why the fuck are there dictionaries in the DB
                del(loadout[entry])
            else:
                loadout.remove(entry)
            edited = True

    if edited:
        to_replace.append([row_id, loadout])

print("Loaded {} rows to update".format(len(to_replace)))

update_qry = "UPDATE characters SET gear=%s WHERE id=%s"
for entry in to_replace:
    cursor.execute(update_qry, [json.dumps(entry[1]), entry[0]])

print("Updates complete")
cursor.close()
print("Saving...")
db.commit()
print("Done!")
