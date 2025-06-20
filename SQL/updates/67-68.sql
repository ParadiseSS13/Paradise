# Updates DB from 67 to 68
# Changes DB default for clientFPS to 60

ALTER TABLE `player` CHANGE COLUMN `clientfps` `clientfps` smallint(4) DEFAULT '60' AFTER `exp`;
