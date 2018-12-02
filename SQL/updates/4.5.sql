#Updating the SQL from version 4 to version 5. -AffectedArc07
#Adding new column to deaths the roundID value.
ALTER TABLE `player`
	ADD `roundid` int(11) NOT NULL AFTER `id`;

#Create table to handle round tracking
CREATE TABLE `round` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `start_datetime` DATETIME NULL,
  `end_datetime` DATETIME NULL,
  `server_ip` INT(15) UNSIGNED NOT NULL,
  `server_port` SMALLINT(5) UNSIGNED NOT NULL,
  `game_mode` VARCHAR(32) NULL,
  `game_mode_result` VARCHAR(64) NULL,
  `station_name` VARCHAR(80) NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;