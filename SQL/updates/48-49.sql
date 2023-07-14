# Updating SQL from 48 to 49 -AffectedArc07
# Add new viewrange toggle
ALTER TABLE `player`
	ADD COLUMN `viewrange` VARCHAR(5) NOT NULL DEFAULT '19x15' AFTER `muted_adminsounds_ckeys`;
