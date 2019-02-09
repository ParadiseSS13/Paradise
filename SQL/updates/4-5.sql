#Updating the SQL from version 4 to version 5. -AffectedArc07
#Creating a table to track discord IDs for round notifying
DROP TABLE IF EXISTS `discord`;
CREATE TABLE IF NOT EXISTS `discord` (
  `ckey` varchar(32) NOT NULL,
  `discord_id` bigint(20) NOT NULL,
  `notify` int(11) NOT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
