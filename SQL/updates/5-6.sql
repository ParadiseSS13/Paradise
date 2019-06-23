#Updating the SQL from version 5 to version 6. -Kyep

#Make a table to track the results of VPN/proxy lookups for IPs (IPINTEL, TG PORT)
CREATE TABLE  `ipintel` (
`ip` INT UNSIGNED NOT NULL ,
`date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL ,
`intel` REAL NOT NULL DEFAULT  '0',
PRIMARY KEY (  `ip` )
) ENGINE = INNODB;

#Make a table to track which ckeys are whitelisted for use of VPNs (IPINTEL, CUSTOM)
CREATE TABLE `vpn_whitelist` (
  `ckey` VARCHAR(32) NOT NULL,
  `reason` text,
  PRIMARY KEY (`ckey`)
) ENGINE=INNODB;

# Add fuid (forum userid) which enables quick lookup of which ckey is associated with a specific forum account. (FORUM LINK)
ALTER TABLE `player` ADD `fuid` BIGINT(20) NULL DEFAULT NULL;
ALTER TABLE `player` ADD INDEX(`fuid`);

# Add fupdate (forum update required) which flags specific ckeys as having been banned/unbanned, which requires an update of their forum/etc permissions (FORUM LINK)
ALTER TABLE `player` ADD `fupdate` SMALLINT(4) NULL DEFAULT 0;
ALTER TABLE `player` ADD INDEX(`fupdate`);

#Make a table to track oauth tokens for linking forum/web accounts (FORUM LINK)
CREATE TABLE `oauth_tokens` (
  `ckey` VARCHAR(32) NOT NULL,
  `token` VARCHAR(32) NOT NULL,
  PRIMARY KEY (`token`)
) ENGINE=INNODB;

#Drop the old 'discord' table that is not used anymore
DROP TABLE `discord`;

# Add afk_watch which gives users the option to make use of the AFK watcher subsystem
ALTER TABLE `player` ADD `afk_watch` tinyint(1) NOT NULL DEFAULT '0';