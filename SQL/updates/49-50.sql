# Updating SQL from 49 to 50 -AffectedArc07
# Add new JSON datum saves table
CREATE TABLE `json_datum_saves` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`ckey` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`slotname` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
	`slotjson` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`created` DATETIME NOT NULL DEFAULT current_timestamp(),
	`updated` DATETIME NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `ckey_unique` (`ckey`, `slotname`) USING BTREE,
	INDEX `ckey` (`ckey`) USING BTREE
) COLLATE = 'utf8mb4_general_ci' ENGINE = InnoDB;
