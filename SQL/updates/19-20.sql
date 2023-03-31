# Updating DB from 19-20, -AffectedArc07
# Tracks round IDs in notes and bans, as well as other admin tweaks

# Add new columns to ban
ALTER TABLE `ban` ADD COLUMN `ban_round_id` INT NULL DEFAULT NULL AFTER `bantime`;
ALTER TABLE `ban` ADD COLUMN `unbanned_round_id` INT NULL DEFAULT NULL AFTER `unbanned_datetime`;


# Add new columns to notes
ALTER TABLE `notes` ADD COLUMN `round_id` INT NULL DEFAULT NULL AFTER `timestamp`;
ALTER TABLE `notes` ADD COLUMN `automated` TINYINT UNSIGNED NULL DEFAULT '0' AFTER `crew_playtime`;

# Add new column to connection_log
ALTER TABLE `connection_log` ADD COLUMN `result` ENUM('ESTABLISHED','DROPPED - IPINTEL', 'DROPPED - BANNED', 'DROPPED - INVALID') NOT NULL DEFAULT 'ESTABLISHED' AFTER `computerid`;
