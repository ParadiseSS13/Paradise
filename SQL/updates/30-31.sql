# Updates DB from 30 to 31 -AffectedArc07
# Creates new tables in preparation for karma conversion

# Rename old tables
RENAME TABLE `karma` TO `karma_log`;
RENAME TABLE `karmatotals` TO `karma_totals`;

# Create new table to track new purchases
CREATE TABLE `karma_purchases` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`ckey` VARCHAR(32) NOT NULL COLLATE 'utf8_general_ci',
	`purchase` VARCHAR(64) NOT NULL COLLATE 'utf8_general_ci',
	`purchase_time` DATETIME NOT NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `ckey` (`ckey`, `purchase`) USING BTREE
) COLLATE='utf8_general_ci' ENGINE=InnoDB;

# YOU MUST NOW RUN 31-32.py
