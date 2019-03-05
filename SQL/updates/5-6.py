# Listen up. 
# In order to run this FUCKING script on Windows, you need to make sure you have Python **3.6.7** installed.
# It won't work on 3.5, it won't work on 2.7, it won't work on fucking 3.7. 
# After you get that shit sorted out, you need to run `pip install mysqlclient==1.3.12`
# If you don't include the ==1.3.12 part, good fucking luck ever getting the piece of fucking shit to build
# Fuck Windows.
# If you're on Linux, you can probably figure out how to install a damn python dependency. https://github.com/PyMySQL/mysqlclient-python
# Have fun. I sure didn't.

#!/usr/bin/env python3
import MySQLdb
import argparse
import struct, socket
import time
from datetime import datetime

parser = argparse.ArgumentParser()
parser.add_argument("address", help="MySQL server address (use localhost for the current computer)")
parser.add_argument("username", help="MySQL login username")
parser.add_argument("password", help="MySQL login password")
parser.add_argument("database", help="Database name")
parser.add_argument("curtable", help="Name of the current feedback table (remember prefixes if you use them)")
parser.add_argument("newtable", help="Name of the new table to insert to, can't be same as the source table (remember prefixes)")

args = parser.parse_args()
db = MySQLdb.connect(host=args.address, user=args.username, passwd=args.password, db=args.database)
cursor = db.cursor()
current_table = args.curtable
new_table = args.newtable

# Populate the target table with legacy data.
cursor.execute("SELECT round_id, var_name, details FROM {0} WHERE var_name IN ( \
'round_start', 'round_end', 'server_ip', 'game_mode', 'round_end_result' )".format(current_table))

var_name_mapping = {
	'round_start': 'start_datetime',
	'round_end': 'end_datetime',
	'server_ip': 'server_ip',
	'game_mode': 'game_mode',
	'round_end_result': 'game_mode_result'
}

rounds = {}

rows = cursor.fetchall()
print("Found ", len(rows), "rows to parse.")
for row in rows:
	round_id = row[0]
	var_name = row[1]
	details = row[2]

	if not round_id in rounds:
		rounds[round_id] = {}

	rounds_obj = rounds[round_id]
	if not var_name_mapping[var_name] in rounds_obj:
		if var_name == 'round_start':
			# 'Wed Mar 21 23:55:05 2018'
			date_obj = datetime.strptime(details, "%a %b %d %H:%M:%S %Y")
			rounds_obj[var_name_mapping[var_name]] = date_obj
			rounds_obj['initialize_datetime'] = date_obj
		elif var_name == 'round_end':
			date_obj = datetime.strptime(details, "%a %b %d %H:%M:%S %Y")
			rounds_obj[var_name_mapping[var_name]] = date_obj
			rounds_obj['shutdown_datetime'] = date_obj
		elif var_name == 'server_ip':
			server_ip_arr = details.split(':')
			if not server_ip_arr[0]:
				server_ip_arr[0] = '0.0.0.0'
			rounds_obj['server_ip'] = struct.unpack("!I", socket.inet_aton(server_ip_arr[0]))[0]
			rounds_obj['server_port'] = int(server_ip_arr[1])
		else:
			rounds_obj[var_name_mapping[var_name]] = details

print("Assembled objects for", len(rounds) ,"rounds.")

for round in rounds:
	round_id = round
	round_obj = rounds[round]

	initialize_datetime =	round_obj["initialize_datetime"]	if "initialize_datetime" in round_obj	else None
	start_datetime =		round_obj["start_datetime"]			if "start_datetime" in round_obj		else None
	end_datetime =			round_obj["end_datetime"]			if "end_datetime" in round_obj			else None
	server_ip =				round_obj["server_ip"]				if "server_ip" in round_obj				else None
	server_port =			round_obj["server_port"]			if "server_port" in round_obj			else None
	game_mode =				round_obj["game_mode"]				if "game_mode" in round_obj				else None
	game_mode_result =		round_obj["game_mode_result"]		if "game_mode_result" in round_obj		else None

	# All of these are required fields in the new system. If they're not present in our compiled data, there's not much we can do.
	if not initialize_datetime or not server_ip or not server_port:
		# print("Round lost:", round_id, round_obj)
		continue

	cursor.execute("SELECT EXISTS(SELECT id FROM {0} WHERE id = {1})".format(new_table, round_id))
	exists = cursor.fetchone()[0]
	if not exists:
		args = (round_id, initialize_datetime, start_datetime, end_datetime, server_ip, server_port, game_mode, game_mode_result)
		query = "INSERT INTO {0} (id, initialize_datetime, start_datetime, end_datetime, server_ip, server_port, game_mode, game_mode_result) \
VALUES (%s, %s, %s, %s, %s, %s, %s, %s)".format(new_table)
		cursor.execute(query, args)

cursor.close()
db.commit()