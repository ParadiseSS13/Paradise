# Guide to database changes

## Intro

Paradise uses a MySQL database to store almost all the data that persists
between rounds. This includes, but is not limited to:

- Preferences

- Characters

- The ingame library

- Round history

- Admin things (notes, bans, connections, etc)

Because of how critical this is, the game has a concept of SQL versions, where
the game will refuse to start if the SQL version expected by the code is not
what is configured in the game configuration file. This is to try and minimise
any bad data writes.

## But what if I want to make changes?

No worries, thats what this guide is for. SQL changes can be broken down into
two types, schema changes and data changes. In short, a schema change is
something which changes the actual table structure within the database, whereas
a data change is just changing the contents inside a table.

- Schema changes require a version update in the `SQL` folder as well as the
  configuration bump, which will be explained below.

- Data changes do not require an SQL version bump as the game can still operate
  without it, there just might be some runtimes between save and load, or some
  old data that needs retroactive adjustment. These reside in
  `tools/pr_sql/xxxxx/` where `xxxxx` is the PR number.

## Schema changes

So, you want to add a new table. In short, you need to do the following:

1. Update the `SQL/paradise_schema.sql` file to ensure the table exists in
  fresh schemas.

2. Create a `SQL/updates/x-y.sql` file. If we are going from DB version 34 to
  35, this file would be `34-35.sql`.

    a. Note that there are some nuances with other files, we will get to that.

3. Bump the SQL version in `config/example/config.toml`. Look for a line
  starting with `sql_version =` and increment it by 1.

4. Bump the `#define SQL_VERSION` by the same amount in
  `code/__DEFINES/misc_defines.dm`.

An example SQL update file is below. It has a comment at the top explaining
what it does, and the schema change below.

```sql
# Updating the SQL from version 61 to version 12. -AffectedArc07
# Adds a new bitflag column for toggles

ALTER TABLE `player` ADD COLUMN `toggles_3` INT NULL DEFAULT NULL AFTER `toggles_2`;
```

Note - the default values in schema updates may differ from what is in the
`SQL/paradise_schema.sql` file, as existing data may need migrating
(more later). Some changes, such as `SQL/updates/57-58.sql` add temporary
columns and/or use a different default to allow for data backfilling. This is
fine, so long as the final state of the column matches with the stock schema
(`SQL/paradise_schema.sql`).

### But my PR needs more complex data operations than a SQL script can provide?

Not to worry, we have provisions in place for this as well. However, it should
be a last resort - do as many transformations as you can within the SQL file
itself.

Some of the scripts are Python files, such as `SQL/updates/38-39.py`. These can
be used for modifying the data in a way that can be done outside of SQL,
however the actual table schema changes should still be a regular SQL file. If
this is the case, having a SQL version update increment of more than 1 is fine.

These files have some rules, most notably:

- SQL credentials should be supplied on the command line as arguments in the
  following format:

    - `python 38-39.py host.ip.goes.here user password database`

    - The only dependency outside of the Python core library should be
      `mysql.connector`. No others please.

Your script can then do whatever it needs to the database. Logging for progress
is advised for heavy operations, but not required. All we ask is that if you do
logs for progress, do it for every 10k rows or so. Don't print for every single
row processed!

The last change needed if you are doing a Python update file is to modify
`tools/ci/generate_sql_scripts.py` to supply the correct command line args.
This tells the CI process to run this as a Python script, not a raw SQL file.

## Data Changes

Data changes are much easier to handle as you do not need to increment the
schema verison, you simply need to create an SQL or Python script inside of
`tools/pr_sql/xxxxx/` where `xxxxx` is your PR number. Don't worry, you can
commit it after the PR is opened so you know the PR number, similar to using
`UpdatePaths`.

The ruling for SQL scripts and Python scripts is the same. So long as the
schema is the same afterwards and the only extra Python library is
`mysql.connector`, you are free to transform the data in whatever way you
need to get it migrated.
