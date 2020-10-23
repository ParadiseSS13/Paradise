#Updating the SQL from version 13 to version 14. -Kyet


# Add new tables used by backend tooling

CREATE TABLE `ip2group`
(
  `ip` varchar (18) NOT NULL,
  `date` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
  `groupstr` varchar (32) NOT NULL DEFAULT '',
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
ALTER TABLE `ip2group` ADD INDEX(`groupstr`);


# Add search indexes to make the most common DB queries faster

ALTER TABLE `admin` ADD INDEX(`ckey`);
ALTER TABLE `admin_log` ADD INDEX(`adminckey`);
ALTER TABLE `connection_log` ADD INDEX(`ckey`);
ALTER TABLE `connection_log` ADD INDEX(`ip`);
ALTER TABLE `connection_log` ADD INDEX(`computerid`);
ALTER TABLE `customuseritems` ADD INDEX(`cuiCKey`);
ALTER TABLE `donators` ADD INDEX(`ckey`);
ALTER TABLE `library` ADD INDEX(`ckey`);
ALTER TABLE `library` ADD INDEX(`flagged`);
ALTER TABLE `notes` ADD INDEX(`ckey`);
ALTER TABLE `oauth_tokens` ADD INDEX(`ckey`);

# Add player table field for byond account creation date

ALTER TABLE `player` ADD COLUMN `byond_date` DATE;
