# Updates the DB from 62 to 63
# Adds a PDA ringtone option to character setup

ALTER TABLE `characters`
	ADD COLUMN `pda_ringtone` VARCHAR(16) NULL DEFAULT NULL AFTER `cyborg_brain_type`;
