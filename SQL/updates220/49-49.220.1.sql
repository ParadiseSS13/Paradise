# Updating DB from 49 to 49.220.1
# Adds characters.tts_seed ~furior

ALTER TABLE `characters` ADD `tts_seed` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `custom_emotes`;
