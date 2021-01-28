#Updating the SQL from version 12 to version 13. -AffectedArc07
#Modifying the player table to remove old columns and add a new bitflag column for toggles
#Includes conversion from old to new

ALTER TABLE `player` ADD COLUMN `toggles_2` INT NULL DEFAULT '0' AFTER `toggles`;

# The following lines will update the new toggles_2 column based on existing data
UPDATE `player` SET `toggles_2` = `toggles_2` + 1 WHERE `randomslot` = 1;
UPDATE `player` SET `toggles_2` = `toggles_2` + 2 WHERE `nanoui_fancy` = 1;
UPDATE `player` SET `toggles_2` = `toggles_2` + 4 WHERE `show_ghostitem_attack` = 1;
UPDATE `player` SET `toggles_2` = `toggles_2` + 8 WHERE `windowflashing` = 1;
UPDATE `player` SET `toggles_2` = `toggles_2` + 16 WHERE `ghost_anonsay` = 1;
UPDATE `player` SET `toggles_2` = `toggles_2` + 32 WHERE `afk_watch` = 1;

# Remove the old columns
ALTER TABLE `player`
	DROP COLUMN `randomslot`,
	DROP COLUMN `nanoui_fancy`,
	DROP COLUMN `show_ghostitem_attack`,
	DROP COLUMN `windowflashing`,
	DROP COLUMN `ghost_anonsay`,
	DROP COLUMN `afk_watch`;
