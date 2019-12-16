# Updating SQL from ver 9 to 10 - Kyet

# Add the 'playtime_history' table that tracks playtime per player per day
CREATE TABLE `playtime_history` (
  `ckey` varchar(32) NOT NULL,
  `date` DATE NOT NULL,
  `time_living` SMALLINT NOT NULL,
  `time_ghost` SMALLINT NOT NULL,
  PRIMARY KEY (`ckey`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

