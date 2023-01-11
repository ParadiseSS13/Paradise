# Add column to player
ALTER TABLE `player` ADD COLUMN `keybindings` longtext COLLATE 'utf8mb4_unicode_ci' DEFAULT NULL AFTER `discord_name`;
# Add column to characters
ALTER TABLE `characters` ADD COLUMN `custom_emotes` longtext COLLATE 'utf8mb4_unicode_ci' DEFAULT NULL AFTER `tts_seed`;
