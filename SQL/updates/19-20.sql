# Updating DB from 19-20
# Replaces volume (number) column by volume_mixer (text) ~dearmochi

# Add column to player
ALTER TABLE `player` ADD COLUMN `volume_mixer` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `volume`;

# Remove column from player
ALTER TABLE `player` DROP COLUMN `volume`;
