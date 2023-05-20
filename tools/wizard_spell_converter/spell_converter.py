import mysql.connector, argparse, json, time, sys
from mysql.connector import errorcode

parser = argparse.ArgumentParser()
parser.add_argument("--address", help="SQL server address (Use 127.0.0.1 for the current computer)")
parser.add_argument("--username", help="SQL login username")
parser.add_argument("--password", help="SQL login password")
parser.add_argument("--database", help="Database name (Default: paradise_gamedb)")

args = parser.parse_args()

try:
    db = mysql.connector.connect(host=args.address, user=args.username, password=args.password, database=args.database)
except mysql.connector.Error as exception:
    if exception.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("Provided username and/or password invalid.")
    elif exception.errno == errorcode.ER_BAD_DB_ERROR:
        print("Database does not exist.")
    else:
        print(exception)
    sys.exit()

cursor = db.cursor()

startwatch = time.time()

try:
    with open('spell_converter.json') as json_file:
        convert_dict = json.load(json_file)
except FileNotFoundError:
    print("Could not find the conversion file. Please make sure you're running the script from tools/wizard_spell_converter/, not the repo root!")
    sys.exit()

for spell in convert_dict:
    query = "UPDATE feedback SET json = replace(json, %s, %s) WHERE key_name = 'wizard_spell_learned'"
    cursor.execute(query, (spell, convert_dict[spell]))
db.commit()

stopwatch = time.time()
print("Database updated in {} seconds!".format(round(stopwatch - startwatch)))
