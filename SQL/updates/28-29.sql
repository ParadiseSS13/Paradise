# Updates DB from 28 to 29 -S34N_W
# Adds support for screentips
ALTER TABLE `player` ADD COLUMN `screentip_mode` tinyint(1) DEFAULT '8';
ALTER TABLE `player` ADD COLUMN `screentip_color` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#ffd391'
