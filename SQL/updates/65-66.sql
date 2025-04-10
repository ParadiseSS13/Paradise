#Updates the DB from 65 to 66
#Adds a column to the characters table that stores quirks in a JSON format
ALTER TABLE `characters`
	ADD column `quirks` LONGTEXT COLLATE 'utf8mb4_unicode_ci' DEFAULT NULL AFTER `species_subtype`;
