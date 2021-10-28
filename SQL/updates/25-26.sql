# Updates DB from 25-25, -AffectedArc07
# Adds a pAI saves table to the DB

CREATE TABLE `pai_saves` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`ckey` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`pai_name` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`description` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`preferred_role` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`ooc_comments` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `ckey` (`ckey`) USING BTREE
) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;
