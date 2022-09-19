# AffectedArc07 2021-10-04
import struct, os, mysql.connector, argparse, html
from datetime import datetime

TYPE_NULL = 0x0
TYPE_STRING = 0x1
TYPE_NUMBER = 0x4

KEY_XOR_KEY = 0x53
DATA_XOR_KEY = 0x3A

KEY_LEN_OFFSET = 8
KEY_OFFSET = 9

# Might be shitcode but mehhhhhhhhhhh
class Decoder:
	def __init__(self, data, key, jump=9):
		self.generator = self.decode_data(data, key, jump)

	def read_bytes(self, num):
		return [next(self.generator) for _ in range(num)]

	def read_all_bytes(self):
		result = []
		for val in self.generator:
			result.append(val)
		return result

	def read_number(self):
		return struct.unpack("<f", bytes(self.read_bytes(4)))[0]

	def read_string(self, length):
		return "".join([chr(c) for c in self.read_all_bytes()])

	def decode_data(self, data, key, jump):
		for byte in data:
			yield byte ^ key
			key = (key + jump) % 256



def decode_sav(path):
	file = open(path, "rb")
	is_file_header = True
	result = {}

	while True:
		entry_header = file.read(5)
		if len(entry_header) < 5:
			break

		entry_length = int.from_bytes(entry_header[:-1], byteorder='little')

		entry_data = file.read(entry_length)

		if entry_header[4] != 1:
			continue

		if is_file_header:
			is_file_header = False
			continue

		key_length = entry_data[KEY_LEN_OFFSET]
		key_data = entry_data[KEY_OFFSET:KEY_OFFSET+key_length]
		key_data = Decoder(key_data, KEY_XOR_KEY).read_string(key_length)

		if not key_data: continue

		data_length_offset = KEY_OFFSET + key_length
		data_length = int.from_bytes(entry_data[data_length_offset:data_length_offset+4], "little")
		data_start = data_length_offset + 4

		value = None

		decoder = Decoder(entry_data[data_start:data_start+data_length], DATA_XOR_KEY)
		typ = decoder.read_bytes(1)[0]
		if typ == TYPE_NULL:
			value = None
		elif typ == TYPE_NUMBER:
			value = decoder.read_number()
		elif typ == TYPE_STRING:
			length = int.from_bytes(decoder.read_bytes(2), "little")
			value = decoder.read_string(length)

		result[key_data] = value
	return result

# Get outer dirs
basepath = "data/player_saves"

all_saves = []
start = datetime.now()
for dir in os.listdir(basepath):
	for dir2 in os.listdir("{}/{}".format(basepath, dir)):
		pai_data = decode_sav("{}/{}/{}/pai.sav".format(basepath, dir, dir2))
		save_data = {}
		save_data["name"] = pai_data["name"] if "name" in pai_data else None
		save_data["description"] = pai_data["description"] if "description" in pai_data else None
		save_data["role"] = pai_data["role"] if "role" in pai_data else None
		save_data["comments"] = pai_data["comments"] if "comments" in pai_data else None
		save_data["version"] = int(pai_data["version"]) if "version" in pai_data else None
		save_data["ckey"] = dir2
		all_saves.append(save_data)

parser = argparse.ArgumentParser()
parser.add_argument("host", help="SQL server host")
parser.add_argument("user", help="SQL login user")
parser.add_argument("pw", help="SQL login pass")
parser.add_argument("db", help="DB name")

args = parser.parse_args()
db = mysql.connector.connect(host=args.host, user=args.user, password=args.pw, database=args.db)
cursor = db.cursor()
stmt = "INSERT INTO pai_saves (ckey, pai_name, description, preferred_role, ooc_comments) VALUES (%s, %s, %s, %s, %s)"

for entry in all_saves:
    if entry["name"]:
        entry["name"] = html.unescape(entry["name"])
    if entry["description"]:
        entry["description"] = html.unescape(entry["description"])
    if entry["role"]:
        entry["role"] = html.unescape(entry["role"])
    if entry["comments"]:
        entry["comments"] = html.unescape(entry["comments"])

    values = (entry["ckey"], entry["name"], entry["description"], entry["role"], entry["comments"])
    cursor.execute(stmt, values)

db.commit()

duration = datetime.now() - start
print("Complete within {}.{}s".format(duration.seconds, duration.microseconds))
