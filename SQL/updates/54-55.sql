# Updating SQL from 54 to 55 -Octus
# Adds a new cultural_language column to characters

ALTER TABLE `characters`
	ADD COLUMN `cultural_language` VARCHAR(45) COLLATE utf8mb4_unicode_ci NOT NULL AFTER `language`;
