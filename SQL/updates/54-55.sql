# Updating DB from 54-55 - lewc
# Adds a new `body_type` (gender sprite) column to the `characters` table

# Add the new column next to the existing `gender` one
ALTER TABLE `characters`
	ADD COLUMN `body_type` varchar(11) COLLATE utf8mb4_unicode_ci NOT NULL AFTER `gender`;

# Set the `body_type` column to whatever's already in `gender`, so that it doesn't change existing characters
UPDATE `characters` SET `body_type` = `gender` WHERE `gender` IS NOT NULL
