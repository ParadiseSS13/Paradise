# :wave: hello fellow contributors, this script is brought to you ad-free by -sirryan2002-
# In order to run this script on Windows, you need to make sure you have Python **3** installed. Tested on 3.10.4
# In addition you must have the mysql-connector-python module installed (can be done through pip :D)
# if you do not have that module installed, you cannot run this script

# To run this, supply the following args in a command shell
# python 36-37.py address username password database
# Example:
# python 36-37.py 127.0.0.1 sirryan2002 myubersecretdbpassword paradise_gamedb

import json
import mysql.connector, argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("address", help="MySQL server address (use localhost for the current computer)")
    parser.add_argument("username", help="MySQL login username")
    parser.add_argument("password", help="MySQL login password")
    parser.add_argument("database", help="Database name")

    args = parser.parse_args()
    db = mysql.connector.connect(host=args.address, user=args.username, passwd=args.password, db=args.database)
    cursor = db.cursor()
    print("Connected to {}".format(args.database))
    #A List of old categories names + the new id number they will be assigned
    category_name_to_id_map = {
        "Fiction":1,
        "Non-Fiction":2,
        "Adult":0,          #0 represents a "removed"/unused category that no longer will be included
        "Reference":16,
        "Religion":3,
    }

    cursor.execute("SELECT id, title, category, content FROM library")
    data = cursor.fetchall()

    print("Loaded {} rows from library table...".format(len(data)))

    new_rows = []
    remove_rows = []
    print("Modifying Categories...")
    for entry in data:
        book_id = entry[0]
        title = entry[1]
        category = entry[2]
        content = entry[3]
        update_entry = False
        new_entry = [
            book_id,
            title,
            category,
            content,
        ]
        if category not in category_name_to_id_map.keys():
            update_entry = True
            new_entry[2] = 0
            print("Corrupted Category Detected: removing \"{}\"...".format(category))
        else:
            for cat in category_name_to_id_map.keys():
                if cat == category:
                    update_entry = True
                    new_entry[2] = category_name_to_id_map[cat]
        if update_entry:
            new_rows.append(new_entry)
        else:
            print("ERROR: Book {} did not have its category changed".format(book_id))

    print("Modifying Content...")
    for entry in new_rows:
        new_content = json.dumps([entry[3]])
        entry[3] = new_content
        #here we're turning our content string into a JSON list
    print("Modified Content...")
    print("Vetting Book Titles & Contents...")
    duplicate_books = 0
    programmatic_books = 0
    notitle_books = 0
    short_books = 0
    for entry in new_rows:
        if "Print Job" in entry[1]:
            print("Book {} had \"Book Job\" in title: removing record...".format(entry[0]))
            notitle_books += 1
            remove_rows.append(entry)
            new_rows.remove(entry)
            continue
        if "Standard Operating Procedure" in entry[1] or "<iframe" in entry[1]:
            print("Book {} named \"{}\" is programattic: removing record...".format(entry[0], entry[1]))
            programmatic_books += 1
            remove_rows.append(entry)
            new_rows.remove(entry)
            continue
        if len(entry[3]) < 150:
            print("Book {} is less than 150 characters: removing record...".format(entry[0]))
            short_books += 1
            remove_rows.append(entry)
            new_rows.remove(entry)
            continue
        for book in new_rows:
            if entry[1] == book[1] and entry != book:
                if entry[3] == book[3]:
                    print("Book {} and Book {} have the same title and content: removing record {}...".format(entry[0],book[0],book[0]))
                    remove_rows.append(book)
                    new_rows.remove(book)
                    duplicate_books += 1
        #here we're turning our content string into a JSON list
    print("All Books vetted, books marked for deletion report:")
    print("Duplicate Books:{}".format(duplicate_books))
    print("No Title Books:{}".format(notitle_books))
    print("Programmatic Books:{}".format(programmatic_books))
    print("Short Books:{}".format(short_books))
    print("Total Books Marked for Deletion: {}".format(len(remove_rows)))
    print("Generated {} rows to insert into new table".format(len(new_rows)))

    if len(new_rows) == 0:
        print("ERROR: No rows have been modfied, no update will be commited")


    print("Inserting...")
    for row in new_rows:
        data = [row[2],row[3],row[0]]
        sql_query = "UPDATE library SET category=%s, content=%s WHERE id=%s"
        cursor.execute(sql_query, data)


    print("removing {} marked records...".format(len(remove_rows)))
    for row in remove_rows:
        data = [row[0]]
        sql_query = "DELETE FROM library WHERE id=%s"
        cursor.execute(sql_query, data)

    print("Adding Summary Column")
    cursor.execute("ALTER TABLE library ADD COLUMN summary MEDIUMTEXT DEFAULT ''")
    print("Adding Ratings Column")
    cursor.execute("ALTER TABLE library ADD COLUMN ratings DOUBLE DEFAULT 0")
    cursor.execute("ALTER TABLE library ADD COLUMN raters MEDIUMTEXT DEFAULT ''")
    print("Updating Flagged Column")
    cursor.execute("ALTER TABLE library MODIFY COLUMN flagged MEDIUMTEXT")
    cursor.execute("UPDATE library SET flagged=''")
    cursor.execute("ALTER TABLE library RENAME COLUMN flagged TO reports")
    print("Updating/Adding new Categories columns")
    cursor.execute("ALTER TABLE library MODIFY COLUMN category INT")
    cursor.execute("ALTER TABLE library RENAME COLUMN category to primaryCategory")
    cursor.execute("ALTER TABLE library ALTER primaryCategory SET DEFAULT 0")
    cursor.execute("ALTER TABLE library ADD COLUMN secondaryCategory INT DEFAULT 0")
    cursor.execute("ALTER TABLE library ADD COLUMN tertiaryCategory INT DEFAULT 0")
    cursor.close()
    print("Saving...")
    db.commit()
    print("Done!")

#this is a script not a library
if __name__ == "__main__":
    main()
