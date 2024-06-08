# Updating SQL from 56 to 57 - MrRomainzZ and Burza
# Add light settings to player preferences

ALTER TABLE `player`
	ADD COLUMN `light` MEDIUMINT(3) DEFAULT '7' AFTER `sound`,
	ADD COLUMN `glowlevel` TINYINT(1) DEFAULT '1' AFTER `light`;
