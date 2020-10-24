#Updating the SQL from version 13 to version 14. -Kyet


# Add new tables used by backend tooling

CREATE TABLE `ip2group` (
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

# Delete pointless indexes
DROP INDEX ckey_UNIQUE ON privacy;

# Add more search indexes to account for the custom indexes we already had but which downstreams do not and were not in the schema

ALTER TABLE `characters` ADD INDEX(`ckey`);
ALTER TABLE `ban` ADD INDEX(`ckey`);
ALTER TABLE `ban` ADD INDEX(`computerid`);
ALTER TABLE `ban` ADD INDEX(`ip`);
ALTER TABLE `player` ADD INDEX(`lastseen`);
ALTER TABLE `player` ADD INDEX(`computerid`);
ALTER TABLE `player` ADD INDEX(`ip`);
ALTER TABLE `player` ADD INDEX(`fuid`);
ALTER TABLE `player` ADD INDEX(`fupdate`);
ALTER TABLE `karmatotals` CHANGE COLUMN `byondkey` `byondkey` VARCHAR(32) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci' AFTER `id`;
ALTER TABLE `karmatotals` CHANGE COLUMN `karmaspent` `karmaspent` int(11) NOT NULL DEFAULT 0 AFTER `karma`;
ALTER TABLE `karmatotals` ADD INDEX(`byondkey`);
ALTER TABLE `whitelist` CHANGE COLUMN `ckey` `ckey` VARCHAR(32) NOT NULL DEFAULT '' AFTER `id`;
ALTER TABLE `whitelist` CHANGE COLUMN `job` `job` MEDIUMTEXT AFTER `ckey`;
ALTER TABLE `whitelist` CHANGE COLUMN `species` `species` MEDIUMTEXT AFTER `job`;
ALTER TABLE `whitelist` ADD INDEX(`ckey`);

# Add player table field for byond account creation date

ALTER TABLE `player` ADD COLUMN `byond_date` DATE;
