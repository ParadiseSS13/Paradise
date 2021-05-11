# Updating DB from 22-23,
# Adds a new `body_type` (gender sprite) column to the `characters` table

# Add the new column next to the existing `gender` one
ALTER TABLE `characters` ADD COLUMN `body_type` varchar(11) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT `gender` AFTER `gender`;
