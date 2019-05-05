#Updating the SQL from version 5 to version 6. -Kyep
#Creating a table to track the results of VPN/proxy lookups for IPs
CREATE TABLE  `ipintel` (
`ip` INT UNSIGNED NOT NULL ,
`date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL ,
`intel` REAL NOT NULL DEFAULT  '0',
PRIMARY KEY (  `ip` )
) ENGINE = INNODB;