# Updating SQL from ver 9 to 10 - Kyet

# Add the 'playtime_history' table that tracks playtime per player per day
CREATE TABLE `playtime_history` (
  `ckey` varchar(32) NOT NULL,
  `date` DATE NOT NULL,
  `time_living` SMALLINT NOT NULL,
  `time_ghost` SMALLINT NOT NULL,
  PRIMARY KEY (`ckey`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

# Add the 'connection_log' table, which is used to log all connections to the server
DROP TABLE IF EXISTS `connection_log`;
CREATE TABLE `connection_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` varchar(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

# Add the 'crew_playtime' field to the 'notes' table, which gives admins some idea of how many hours have passed for a player since they got a note
ALTER TABLE `notes` ADD `crew_playtime` mediumint(8) UNSIGNED DEFAULT '0' AFTER `server`;
