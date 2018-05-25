#Updating the SQL from version 2 to version 3. -alffd
#Droping privacy table and recreating for terms of service tracking
DROP TABLE `privacy`;
CREATE TABLE `privacy` (
  `ckey` varchar(32) NOT NULL,
  `datetime` datetime NOT NULL,
  `consent` varchar(128) NOT NULL,
  PRIMARY KEY (`ckey`),
  UNIQUE KEY `ckey_UNIQUE` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
