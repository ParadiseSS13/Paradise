# Updates DB from 33 to 34 -AffectedArc07
# Fixes new players not getting the default toggles_2 value
ALTER TABLE `player` CHANGE COLUMN `toggles_2` `toggles_2` INT(11) NULL DEFAULT NULL AFTER `toggles`;

UPDATE `player` SET `toggles_2` = null WHERE `toggles_2` = 0;

# Only run the below script if you wish to manually set everyones toggles_2 to the defaults
UPDATE `player` SET `toggles_2` = `toggles_2` + 2 WHERE (`toggles_2` & 2) != 2;
UPDATE `player` SET `toggles_2` = `toggles_2` + 4 WHERE (`toggles_2` & 4) != 4;
UPDATE `player` SET `toggles_2` = `toggles_2` + 8 WHERE (`toggles_2` & 8) != 8;
UPDATE `player` SET `toggles_2` = `toggles_2` + 64 WHERE (`toggles_2` & 64) != 64;
UPDATE `player` SET `toggles_2` = `toggles_2` + 128 WHERE (`toggles_2` & 128) != 128;
UPDATE `player` SET `toggles_2` = `toggles_2` + 256 WHERE (`toggles_2` & 256) != 256;
UPDATE `player` SET `toggles_2` = `toggles_2` + 512 WHERE (`toggles_2` & 512) != 512;
