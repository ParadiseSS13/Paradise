# Updates the DB from 63 to 64 ~SpaghettiBit
# Adds a subtype race to be stored on character saves
# Add species_subtype after pda_ringtone
ALTER TABLE `characters`
	ADD COLUMN `species_subtype` VARCHAR(45) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'None' AFTER `pda_ringtone`;
