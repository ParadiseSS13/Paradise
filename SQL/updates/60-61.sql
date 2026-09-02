# Updates the DB from 60 to 61 ~Qwertytoforty
# Makes a table for map picks

# Adds the table for it.
ALTER TABLE `player`
	ADD COLUMN `map_vote_pref_json` MEDIUMTEXT NULL DEFAULT NULL AFTER `viewrange`;