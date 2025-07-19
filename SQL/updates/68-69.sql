# Updates DB from 68 to 69
# Changes DB default for clientFPS to 100

ALTER TABLE `player` CHANGE COLUMN `clientfps` `clientfps` smallint(4) DEFAULT '100' AFTER `exp`;
