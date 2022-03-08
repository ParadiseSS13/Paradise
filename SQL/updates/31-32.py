# Listen up.
# In order to run this script on Windows, you need to make sure you have Python **3** installed. Tested on 3.8.2
# It won't work on 2.7 at all.

# To run this, supply the following args in a command shell
# python 31-32.py address username password database
# Example:
# python 31-32.py 172.16.0.200 affectedarc07 (redacted) paradise_gamedb

#!/usr/bin/env python3
import mysql.connector, argparse
from mysql.connector.errors import IntegrityError

parser = argparse.ArgumentParser()
parser.add_argument("address", help="MySQL server address (use localhost for the current computer)")
parser.add_argument("username", help="MySQL login username")
parser.add_argument("password", help="MySQL login password")
parser.add_argument("database", help="Database name")

args = parser.parse_args()
db = mysql.connector.connect(host=args.address, user=args.username, passwd=args.password, db=args.database)
cursor = db.cursor()

# Dictionaries of old & new purchase IDs
job_purchase_map = {
    "Blueshield": "JOB_Blueshield",
    "Barber": "JOB_Barber",
    "Brig Physician": "JOB_BrigPhysician",
    "Nanotrasen Representative": "JOB_NanotrasenRepresentative",
    "Security Pod Pilot": "JOB_SecurityPodPilot",
    "Mechanic": "JOB_Mechanic",
    "Magistrate": "JOB_Magistrate"
}

species_purchase_map = {
    "Grey": "SPECIES_Grey",
    "Kidan": "SPECIES_Kidan",
    "Slime People": "SPECIES_SlimePeople",
    "Vox": "SPECIES_Vox",
    "Drask": "SPECIES_Drask",
    "Machine": "SPECIES_Machine",
    "Plasmaman": "SPECIES_Plasmaman"
}

print("Connected")

cursor.execute("SELECT ckey, job, species FROM whitelist")
data = cursor.fetchall()

print("Loaded {} rows from old table".format(len(data)))

new_rows = []

for entry in data:
    job_set = entry[1]
    species_set = entry[2]

    # Account for null entries
    if job_set is not None:
        jobs = job_set.split(",")
    else:
        jobs = []

    if species_set is not None:
        species = species_set.split(",")
    else:
        species = []

    if len(jobs) > 0:
        for job in jobs:
            if job in job_purchase_map:
                new_job = job_purchase_map[job]
                new_row = [entry[0], new_job]
                new_rows.append(new_row)

    if len(species) > 0:
        for race in species:
            if race in species_purchase_map:
                new_species = species_purchase_map[race]
                new_row = [entry[0], new_species]
                new_rows.append(new_row)

print("Generated {} rows to insert into new table".format(len(new_rows)))

stmt = "INSERT INTO karma_purchases (ckey, purchase) VALUES (%s, %s)"

print("Inserting...")
for row in new_rows:
    data = (row[0], row[1])
    try:
        cursor.execute(stmt, data)
    except IntegrityError:
        print("{} already had {} as a purchase. They may be eligble for compensation".format(row[0], row[1])) # They had an accident that wasnt their fault

cursor.close()
print("Saving...")
db.commit()
print("Done!")
