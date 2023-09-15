# Updating SQL from 51 to 52 -Octus
# Add characther descriptors of height and build to preference menu

ALTER TABLE `characters`
	ADD COLUMN `physique` VARCHAR(45) NULL DEFAULT NULL AFTER `nanotrasen_relation`,
	ADD COLUMN `height` VARCHAR(45) NULL DEFAULT NULL AFTER `physique`;
