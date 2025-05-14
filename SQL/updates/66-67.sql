#Updates the DB from 66 to 67
#Adds a column to the characters table that stores quirks in a JSON format
ALTER TABLE `characters`
	ADD column `quirks` LONGTEXT COLLATE 'utf8mb4_unicode_ci' DEFAULT NULL AFTER `pda_ringtone`;
