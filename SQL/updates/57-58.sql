# Updates the DB from 57 to 58 -SpaghettiBit
# Adds a runechat color preference to characters.

ALTER TABLE `characters` MODIFY COLUMN `real_name` varchar(55) COLLATE utf8mb4_unicode_ci NOT NULL

# Add runechat color after hair_gradient_alpha
ALTER TABLE `characters`
	ADD COLUMN `runechat_color` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL AFTER `hair_gradient_alpha`;

# Sets the default runechat color of existing characters to white.
	UPDATE `characters` SET `runechat_color` = `#FFFFFF`
