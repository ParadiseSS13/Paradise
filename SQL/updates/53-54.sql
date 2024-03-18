# Updating SQL from 53 to 54 -MrRomainzZ
# Add characther descriptors of height and build to preference menu

ALTER TABLE `player`
	ADD COLUMN `old_lighting` TINYINT(1) NULL DEFAULT NULL AFTER `viewrange`,
	ADD COLUMN `glowlevel` TINYINT(1) NULL DEFAULT NULL AFTER `old_lighting`,
	ADD COLUMN `lampsexposure` TINYINT(1) NULL DEFAULT NULL AFTER `glowlevel`,
	ADD COLUMN `lampsglare` TINYINT(1) NULL DEFAULT NULL AFTER `lampsexposure`;
