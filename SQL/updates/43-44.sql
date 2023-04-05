# Updating SQL from 43 to 44 -AffectedArc07
# Adding new column for server region settings
ALTER TABLE `player` ADD COLUMN `server_region` VARCHAR(32) NULL DEFAULT NULL AFTER `keybindings`;
