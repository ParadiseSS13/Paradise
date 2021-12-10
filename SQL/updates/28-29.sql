# Updates DB from 28 to 29 -S34N_W
# Adds support for persistent ghost darkness
ALTER TABLE `player` ADD COLUMN `ghost_darkness_level` tinyint(1) UNSIGNED NOT NULL DEFAULT '255'
