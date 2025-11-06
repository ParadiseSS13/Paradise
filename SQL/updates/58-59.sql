# Updates the DB from 58 to 59 ~SpaghettiBit
# Adds a runechat color preference to characters.

# Add runechat color after hair_gradient_alpha
ALTER TABLE `characters`
	ADD COLUMN `runechat_color` VARCHAR(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#FFFFFF' AFTER `hair_gradient_alpha`;
