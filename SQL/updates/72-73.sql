# Updating SQL from 72 to 73
# Adds a new table for tracking player achievements and their metadata
# Also adds an achievements_sound preference column to the player table

DROP TABLE IF EXISTS `achievements`;
CREATE TABLE `achievements` (
    `ckey` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
    `achievement_key` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
    `value` INT NULL DEFAULT NULL,
    `last_updated` DATETIME NOT NULL DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`ckey`, `achievement_key`)
)
COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;

DROP TABLE IF EXISTS `achievement_metadata`;
CREATE TABLE `achievement_metadata` (
    `achievement_key` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
    `achievement_version` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    `achievement_type` ENUM('achievement','score','award') NULL DEFAULT NULL,
    `achievement_name` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
    `achievement_description` VARCHAR(512) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
    PRIMARY KEY (`achievement_key`)
)
COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;

ALTER TABLE `player` ADD COLUMN `achievements_sound` VARCHAR(50) NOT NULL DEFAULT 'Success Ping' COLLATE 'utf8mb4_general_ci';
