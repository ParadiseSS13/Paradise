# This script will read your deaths table and assign round IDs from the round table

# To run this, supply the following args in a command shell
# Example:
# python death_rid_parser.py 172.16.0.200 affectedarc07 (redacted) paradise_gamedb

#!/usr/bin/env python3
import mysql.connector, argparse

parser = argparse.ArgumentParser()
parser.add_argument("address", help="MySQL server address (use localhost for the current computer)")
parser.add_argument("username", help="MySQL login username")
parser.add_argument("password", help="MySQL login password")
parser.add_argument("database", help="Database name")

args = parser.parse_args()
db = mysql.connector.connect(host=args.address, user=args.username, passwd=args.password, db=args.database)
cursor = db.cursor()
print("Connected")

print("Loading round timing map")
round_times_map = []

# Get all the time maps
cursor.execute("SELECT id, initialize_datetime FROM round ORDER BY initialize_datetime ASC")
all_rounds = cursor.fetchall()
last_round = None


for round in all_rounds:
    round_obj = {}
    round_obj["rid"] = round[0]
    round_obj["stime"] = round[1]

    if last_round:
        last_round["etime"] = round[1]

    last_round = round_obj
    round_times_map.append(round_obj)

first_logged_round = None
print("Round times loaded, getting first round ID to get first death")
cursor.execute("SELECT MIN(initialize_datetime) FROM round")
first_logged_round = cursor.fetchone()[0]
print("First logged round init time is {} | Only loading deaths since then".format(first_logged_round))
print("This will take a while")


print("Pulling data")
# Now get all the deaths
cursor.execute("SELECT id, tod FROM death WHERE tod >= %s ORDER BY tod ASC", [first_logged_round])
all_deaths = cursor.fetchall()
print("Found {} deaths to assign round IDs to".format(len(all_deaths)))

replacement_map = {}
round_idx = 0
current_round = round_times_map[round_idx]


print("Beginning iteration")
for death in all_deaths:
    # If the death time is after the current round
    while death[1] > current_round["etime"]:
        round_idx += 1
        current_round = round_times_map[round_idx]

    if (death[1] >= current_round["stime"]) and (death[1] <= current_round["etime"]):
        replacement_map[str(death[0])] = current_round["rid"]
    else:
        # I tested this on prod data, it never happened
        print("WHAT?!")
        print(death)
        print(current_round)

print("Updating the existing death rows")

for death_id in replacement_map:
    cursor.execute("UPDATE death SET death_rid=%s WHERE id=%s", [replacement_map[death_id], death_id])

cursor.close()
print("Saving...")
db.commit()
print("Done!")
