#Updating the SQL from version 5 to version 6. -Kyep

#Make a table to track the results of VPN/proxy lookups for IPs (IPINTEL, TG PORT)
DROP TABLE IF EXISTS `ipintel`;
CREATE TABLE `ipintel` (
  `ip` int UNSIGNED NOT NULL,
  `date` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
  `intel` real NOT NULL DEFAULT '0',
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#Make a table to track which ckeys are whitelisted for use of VPNs (IPINTEL, CUSTOM)
DROP TABLE IF EXISTS `vpn_whitelist`;
CREATE TABLE `vpn_whitelist` (
  `ckey` varchar(32) NOT NULL,
  `reason` text,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#Add fuid (forum userid) which enables quick lookup of which ckey is associated with a specific forum account. (FORUM LINK)
ALTER TABLE `player` ADD `fuid` bigint(20) NULL DEFAULT NULL;
ALTER TABLE `player` ADD INDEX(`fuid`);

#Add fupdate (forum update required) which flags specific ckeys as having been banned/unbanned, which requires an update of their forum/etc permissions (FORUM LINK)
ALTER TABLE `player` ADD `fupdate` smallint(4) NULL DEFAULT 0;
ALTER TABLE `player` ADD INDEX(`fupdate`);

#Make a table to track oauth tokens for linking forum/web accounts (FORUM LINK)
DROP TABLE IF EXISTS `oauth_tokens`;
CREATE TABLE `oauth_tokens` (
  `ckey` varchar(32) NOT NULL,
  `token` varchar(32) NOT NULL,
  PRIMARY KEY (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

#Drop the old 'discord' table that is not used anymore
DROP TABLE `discord`;
