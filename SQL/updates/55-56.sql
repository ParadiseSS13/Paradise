# Updating SQL from 55 to 56 - MrRomainzZ
# Add light settings to player preferences

ALTER TABLE `player`
	ADD COLUMN `old_lighting` TINYINT(1) NULL DEFAULT NULL AFTER `viewrange`,
	ADD COLUMN `glowlevel` TINYINT(1) NULL DEFAULT NULL AFTER `old_lighting`,
	ADD COLUMN `lampsexposure` TINYINT(1) NULL DEFAULT NULL AFTER `glowlevel`,
	ADD COLUMN `lampsglare` TINYINT(1) NULL DEFAULT NULL AFTER `lampsexposure`;
