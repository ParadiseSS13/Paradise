# Updating SQL from 45 to 46 -AffectedArc07
# Adds a way to mute soundfiles from specific admins
ALTER TABLE `player`
	ADD COLUMN `muted_adminsounds_ckeys` MEDIUMTEXT NULL DEFAULT NULL AFTER `server_region`;
