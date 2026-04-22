# Updates DB from 72 to 73
# Adds a new table for achievements

DROP TABLE IF EXISTS `achievements`;
CREATE TABLE `achievements` (
	`ckey` VARCHAR(32) NOT NULL,
	`achievement_key` VARCHAR(32) NOT NULL,
	`value` INT NULL,
	`last_updated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`ckey`,`achievement_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `achievement_metadata`;
CREATE TABLE `achievement_metadata` (
	`achievement_key` VARCHAR(32) NOT NULL,
	`achievement_version` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
	`achievement_type` enum('achievement','score','award') NULL DEFAULT NULL,
	`achievement_name` VARCHAR(64) COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
	`achievement_description` VARCHAR(512) COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
	PRIMARY KEY (`achievement_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `player` ADD COLUMN `achivements_sound` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Success Ping';
