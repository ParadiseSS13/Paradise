# Updates DB from 23 to 24 -AffectedArc07
# Add new column to player table for 2FA status
ALTER TABLE `player` ADD COLUMN `2fa_status` ENUM('DISABLED','ENABLED_IP','ENABLED_ALWAYS') NOT NULL DEFAULT 'DISABLED' AFTER `byond_date`;

# Create new table for 2FA tokens
CREATE TABLE `2fa_secrets` (
	`ckey` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`secret` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`date_setup` DATETIME NOT NULL DEFAULT current_timestamp(),
	`last_time` DATETIME NULL DEFAULT NULL,
	PRIMARY KEY (`ckey`) USING BTREE
)
COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;
