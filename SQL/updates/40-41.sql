# Updating DB from 40-41
# Adds player.keybindings (longtext) ~dearmochi

# Add column to player
ALTER TABLE `player` ADD COLUMN `keybindings` LONGTEXT COLLATE 'utf8mb4_unicode_ci' DEFAULT NULL AFTER `colourblind_mode`;
