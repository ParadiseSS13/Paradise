# Updating DB from 64-65 ~Contrabang
# Adds a new column to the notes table for public notes
ALTER TABLE `notes`
	ADD COLUMN `public` TINYINT NOT NULL DEFAULT 0 AFTER `deletedby`,
	ADD INDEX `public` (`public`);
