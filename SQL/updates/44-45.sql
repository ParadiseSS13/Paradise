# Updating SQL from 44 to 45 -AffectedArc07
# Adding new table for a ticket log
CREATE TABLE `tickets` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`ticket_num` INT(11) NOT NULL,
	`ticket_type` ENUM('ADMIN','MENTOR') NOT NULL COLLATE 'utf8mb4_general_ci',
	`real_filetime` DATETIME NOT NULL,
	`relative_filetime` TIME NOT NULL,
	`ticket_creator` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
	`ticket_topic` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`ticket_taker` VARCHAR(32) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`ticket_take_time` DATETIME NULL DEFAULT NULL,
	`all_responses` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`awho` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`end_round_state` ENUM('OPEN','CLOSED','RESOLVED','STALE','UNKNOWN') NOT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`id`) USING BTREE,
	CONSTRAINT `all_responses` CHECK (json_valid(`all_responses`)),
	CONSTRAINT `awho` CHECK (json_valid(`awho`))
) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;
