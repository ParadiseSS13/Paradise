CREATE TABLE `budget` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`date` DATETIME NOT NULL DEFAULT current_timestamp(),
	`ckey` VARCHAR(32) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci',
	`amount` INT(10) UNSIGNED NOT NULL,
	`source` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
	`date_start` DATETIME NOT NULL DEFAULT current_timestamp(),
	`date_end` DATETIME NULL DEFAULT (current_timestamp() + interval 1 month),
	`is_valid` TINYINT(1) NOT NULL DEFAULT '1',
	`discord_id` bigint(20) DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE
) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;
