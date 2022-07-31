# Updating DB from 41-42
# Adds characters.custom_emotes (longtext) ~S34N

# Add column to characters
ALTER TABLE `characters` ADD COLUMN `custom_emotes` LONGTEXT COLLATE 'utf8mb4_unicode_ci' DEFAULT NULL AFTER `hair_gradient_alpha`;
