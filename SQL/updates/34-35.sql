# Updates DB from 34 to 35 -hal9000PR
# Changes DB default for clientFPS to 63

ALTER TABLE `player` CHANGE COLUMN `clientfps` `clientfps` smallint(4) DEFAULT '63' AFTER `exp`;
