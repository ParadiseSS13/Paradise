# :wave: hello fellow contributors, this script is brought to you ad-free by AffectedArc07 and Warriorstar
# In order to run this script on Windows, you need to make sure you have Python **3** installed. Tested on 3.10.4
# In addition you must have the mysql-connector-python module installed (can be done through pip :D)
# if you do not have that module installed, you cannot run this script

# To run this, supply the following args in a command shell
# python 62-63.py address username password database
# Example:
# python 62-63.py 127.0.0.1 sirryan2002 myubersecretdbpassword paradise_gamedb

from pathlib import Path
from datetime import datetime
import argparse
import json

import mysql.connector


def log(msg):
    print(f"[{datetime.utcnow()}] {msg}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "address", help="MySQL server address (use localhost for the current computer)"
    )
    parser.add_argument("username", help="MySQL login username")
    parser.add_argument("password", help="MySQL login password")
    parser.add_argument("database", help="Database name")

    args = parser.parse_args()
    db = mysql.connector.connect(
        host=args.address, user=args.username, passwd=args.password, db=args.database
    )
    cursor = db.cursor()
    log(f"Connected to {args.database}")

    # want these ordered by length from longest to shortest so shorter replacements
    # don't replace pieces of larger replacements
    renames = sorted(
        json.load(open(Path(__file__).parent / "snake_case_type_remap.json")),
        key=lambda x: len(x["original"]),
        reverse=True,
    )

    log("feedback: running query")
    cursor = db.cursor()
    cursor.execute(
        """
        SELECT round_id, key_name, json, id
        FROM feedback
        ORDER BY id DESC
        """
    )

    log("feedback: fetching all data")
    rows = cursor.fetchall()
    log(f"feedback: processing {len(rows)} rows...")

    sql_statements = list()
    for row in rows:
        row_replacements = []
        for rename in renames:
            if rename["original"] in row[2]:
                row_replacements.append(rename)
        if row_replacements:
            for replacement in sorted(
                row_replacements, key=lambda x: len(x["original"]), reverse=True
            ):
                update_sql = (
                    """UPDATE feedback SET json = REPLACE(json, %s, %s) WHERE id = %s""",
                    (
                        replacement["original"],
                        replacement.get("override", replacement["replace"]),
                        row[3],
                    ),
                )

                sql_statements.append(update_sql)

    log(f"feedback: running {len(sql_statements)} SQL updates")

    if len(sql_statements) > 0:
        cursor = db.cursor()
        for update_sql in sql_statements:
            cursor.execute(*update_sql)

        log("feedback: committing data")
        db.commit()

    log("json_datum_saves: running query")
    cursor = db.cursor()
    cursor.execute(
        """
        SELECT id, slotjson
        FROM json_datum_saves
        ORDER BY id DESC
        """
    )

    log("json_datum_saves: fetching all data")
    rows = cursor.fetchall()
    log(f"json_datum_saves: processing {len(rows)} rows...")

    sql_statements = list()
    for row in rows:
        row_replacements = []
        for rename in renames:
            if rename["original"] in row[1]:
                row_replacements.append(rename)
        if row_replacements:
            for replacement in sorted(
                row_replacements, key=lambda x: len(x["original"]), reverse=True
            ):
                update_sql = (
                    """UPDATE json_datum_saves SET slotjson = REPLACE(slotjson, %s, %s) WHERE id = %s""",
                    (
                        replacement["original"],
                        replacement.get("override", replacement["replace"]),
                        row[0],
                    ),
                )

                sql_statements.append(update_sql)

    log(f"json_datum_saves: running {len(sql_statements)} SQL updates")

    if len(sql_statements) > 0:
        cursor = db.cursor()
        for update_sql in sql_statements:
            cursor.execute(*update_sql)

        log("json_datum_saves: committing data")
        db.commit()

    log("characters: running query")
    cursor = db.cursor()
    cursor.execute(
        """
        SELECT id, gear
        FROM characters
        ORDER BY id DESC
        """
    )

    log("characters: fetching all data")
    rows = cursor.fetchall()
    log(f"characters: processing {len(rows)} rows...")

    sql_statements = list()
    for row in rows:
        row_replacements = []
        for rename in renames:
            if rename["original"] in row[1]:
                row_replacements.append(rename)
        if row_replacements:
            for replacement in sorted(
                row_replacements, key=lambda x: len(x["original"]), reverse=True
            ):
                update_sql = (
                    """UPDATE characters SET gear = REPLACE(gear, %s, %s) WHERE id = %s""",
                    (
                        replacement["original"],
                        replacement.get("override", replacement["replace"]),
                        row[0],
                    ),
                )

                sql_statements.append(update_sql)

    log(f"characters: running {len(sql_statements)} SQL updates")

    if len(sql_statements) > 0:
        cursor = db.cursor()
        for update_sql in sql_statements:
            cursor.execute(*update_sql)

        log("characters: committing data")
        db.commit()

    log("done.")


if __name__ == "__main__":
    main()
