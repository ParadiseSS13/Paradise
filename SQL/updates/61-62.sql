# Updating the SQL from version 61 to version 12. -AffectedArc07
# Adds a new bitflag column for toggles

ALTER TABLE `player` ADD COLUMN `toggles_3` INT NULL DEFAULT NULL AFTER `toggles_2`;
