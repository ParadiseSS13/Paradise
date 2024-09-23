# Updating DB from 55-56 ~AffectedArc07
# Adds a new column to the notes table for tracking deleted notes
ALTER TABLE `notes`
	ADD COLUMN `deleted` TINYINT NOT NULL DEFAULT 0 AFTER `automated`,
	ADD COLUMN `deletedby` VARCHAR(32) NULL DEFAULT NULL AFTER `deleted`,
	ADD INDEX `deleted` (`deleted`);

