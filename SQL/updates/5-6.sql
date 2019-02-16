#Updating the SQL from version 5 to version 6. -AffectedArc07
#Creating a table to track soapstone messages
DROP TABLE IF EXISTS `soapstone`;
CREATE TABLE IF NOT EXISTS `soapstone` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `coord` text NOT NULL COMMENT 'X, Y, Z',
  `message_text` text NOT NULL,
  `map` text NOT NULL,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
