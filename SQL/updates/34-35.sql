# Updates DB from 34 to 35 -hal9000PR
# Changes DB default for clientFPS to 63

ALTER TABLE `player` CHANGE COLUMN `clientfps` `clientfps` INT(11) DEFAULT '63' AFTER `exp`;
