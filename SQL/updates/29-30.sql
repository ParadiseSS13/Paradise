# Adds support for persistent ghost darkness
ALTER TABLE `player` ADD COLUMN `ghost_darkness_level` tinyint(1) UNSIGNED NOT NULL DEFAULT '255'
