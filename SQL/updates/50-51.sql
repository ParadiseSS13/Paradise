# Updating SQL from 50 to 51 -Edan52
# Add last words to death table
ALTER TABLE `death`
	ADD COLUMN `last_words` text NULL DEFAULT NULL AFTER `death_rid`;
