# Updating SQL from 56 to 57 - MrRomainzZ
# Add light settings to player preferences

ALTER TABLE `player`
	ADD COLUMN `light` mediumint(3) DEFAULT '7' AFTER `sound`,
	ADD COLUMN `glowlevel` tinyint(1) DEFAULT '1' AFTER `light`;
