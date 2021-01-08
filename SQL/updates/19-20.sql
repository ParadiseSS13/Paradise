# Updating DB from 19-20, -AffectedArc07
# Tracks round IDs in notes and bans

# Add new columns to ban
ALTER TABLE `ban` ADD COLUMN `ban_round_id` INT NULL DEFAULT NULL AFTER `bantime`;
ALTER TABLE `ban` ADD COLUMN `unbanned_round_id` INT NULL DEFAULT NULL AFTER `unbanned_datetime`;


# Add new column to notes
ALTER TABLE `notes` ADD COLUMN `round_id` INT NULL DEFAULT NULL AFTER `timestamp`;
