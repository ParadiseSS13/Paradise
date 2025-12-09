from pathlib import Path
from datetime import datetime
import argparse
import json
import mysql.connector


def log(msg):
    print(f"[{datetime.utcnow()}] {msg}")


def update_table(cursor, db, table_name, column_name, renames):
    log(f"{table_name}: running query")
    cursor.execute(f"SELECT id, {column_name} FROM {table_name} ORDER BY id DESC")
    rows = cursor.fetchall()
    log(f"{table_name}: processing {len(rows)} rows...")

    sql_statements = []

    for row in rows:
        row_replacements = [
            rename for rename in renames if rename["original"] in row[1]
        ]
        if row_replacements:
            for replacement in sorted(
                row_replacements, key=lambda x: len(x["original"]), reverse=True
            ):
                sql_statements.append(
                    (
                        f"UPDATE {table_name} SET {column_name} = REPLACE({column_name}, %s, %s) WHERE id = %s",
                        (
                            replacement["original"],
                            replacement["replace"],
                            row[0],
                        ),
                    )
                )

    log(f"{table_name}: running {len(sql_statements)} SQL updates")

    if sql_statements:
        for update_sql in sql_statements:
            cursor.execute(*update_sql)
        log(f"{table_name}: committing data")
        db.commit()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("address", help="MySQL server address (use localhost for the current computer)")
    parser.add_argument("username", help="MySQL login username")
    parser.add_argument("password", help="MySQL login password")
    parser.add_argument("database", help="Database name")

    args = parser.parse_args()
    db = mysql.connector.connect(
        host=args.address, user=args.username, passwd=args.password, db=args.database
    )
    cursor = db.cursor()
    log(f"Connected to {args.database}")

    renames = sorted(
        json.load(open(Path(__file__).parent / "xx_melee_repath_map.json")),
        key=lambda x: len(x["original"]),
        reverse=True,
    )

    tables = [
        ("feedback", "json"),
        ("json_datum_saves", "slotjson"),
        ("characters", "gear"),
    ]

    for table_name, column_name in tables:
        update_table(cursor, db, table_name, column_name, renames)

    log("done.")


if __name__ == "__main__":
    main()
