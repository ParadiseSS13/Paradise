# Updates DB from 25 to 26 -S34N
# Add new column to player table for screentip_color

ALTER TABLE `player` ADD COLUMN `screentip_color` VARCHAR(7) NULL DEFAULT '#b82e00' COLLATE 'utf8mb4_unicode_ci'
