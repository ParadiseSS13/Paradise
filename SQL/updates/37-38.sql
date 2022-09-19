# Updates DB from 37 to 38 -Sirryan2002
# Creates new tables in preparation for library table conversion

#Renames old table
ALTER TABLE library RENAME TO library_old;

# Create new table to track library books
CREATE TABLE `library` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`author` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`title` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`content` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`ckey` VARCHAR(32) NULL DEFAULT '' COLLATE 'utf8mb4_unicode_ci',
	`reports` MEDIUMTEXT NOT NULL COLLATE 'utf8mb3_general_ci',
	`summary` MEDIUMTEXT NOT NULL COLLATE 'utf8mb3_general_ci',
	`rating` DOUBLE NULL DEFAULT '0',
	`raters` MEDIUMTEXT NOT NULL COLLATE 'utf8mb3_general_ci',
	`primary_category` INT(11) NULL DEFAULT '0',
	`secondary_category` INT(11) NOT NULL DEFAULT '0',
	`tertiary_category` INT(11) NULL DEFAULT '0',
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `ckey` (`ckey`) USING BTREE,
	INDEX `flagged` (`reports`(1024)) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

# YOU MUST NOW RUN 38-39.py
