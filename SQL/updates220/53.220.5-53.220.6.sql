# Updating DB from 53.220.5 to 53.220.6
# Adds species whitelist ~legendaxe

ALTER TABLE `player` ADD `species_whitelist` LONGTEXT COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT ('["human"]');
