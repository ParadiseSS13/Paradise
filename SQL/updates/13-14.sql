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



# Add player table field that AA plans to use very soon to store byond account creation date

ALTER TABLE `player` ADD COLUMN `byond_date` DATE;


# These updates change your DB to match what we (Paradise) ALREADY USE IN PRODUCTION
# We (Paradise) do NOT need to run any of these.
# They are included here only for the convenience of github contributors, and downstream servers.

ALTER TABLE `characters` ADD INDEX(`ckey`);

ALTER TABLE `ban` ADD INDEX(`ckey`);
ALTER TABLE `ban` ADD INDEX(`computerid`);
ALTER TABLE `ban` ADD INDEX(`ip`);

ALTER TABLE `library` CHANGE COLUMN `author` `author` MEDIUMTEXT COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `library` CHANGE COLUMN `title` `title` MEDIUMTEXT COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `library` CHANGE COLUMN `content` `content` MEDIUMTEXT COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `library` CHANGE COLUMN `category` `category` MEDIUMTEXT COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `library` CHANGE COLUMN `ckey` `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;

ALTER TABLE `player` CHANGE COLUMN `ckey` `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `player` CHANGE COLUMN `ip` `ip` varchar(18) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `player` CHANGE COLUMN `computerid` `computerid` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `player` CHANGE COLUMN `lastadminrank` `lastadminrank` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Player';
ALTER TABLE `player` CHANGE COLUMN `ooccolor` `ooccolor` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT '#b82e00';
ALTER TABLE `player` CHANGE COLUMN `UI_style` `UI_style` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT 'Midnight';
ALTER TABLE `player` CHANGE COLUMN `UI_style_color` `UI_style_color` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT '#ffffff';
ALTER TABLE `player` CHANGE COLUMN `be_role` `be_role` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL;
ALTER TABLE `player` CHANGE COLUMN `toggles` `toggles` int(11) DEFAULT NULL;
ALTER TABLE `player` CHANGE COLUMN `toggles_2` `toggles_2` int(11) DEFAULT 0;
ALTER TABLE `player` CHANGE COLUMN `lastchangelog` `lastchangelog` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0';
ALTER TABLE `player` CHANGE COLUMN `exp` `exp` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL;
ALTER TABLE `player` ADD INDEX(`lastseen`);
ALTER TABLE `player` ADD INDEX(`computerid`);
ALTER TABLE `player` ADD INDEX(`ip`);
ALTER TABLE `player` ADD INDEX(`fuid`);
ALTER TABLE `player` ADD INDEX(`fupdate`);

ALTER TABLE `karmatotals` CHANGE COLUMN `byondkey` `byondkey` VARCHAR(32) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci' AFTER `id`;
ALTER TABLE `karmatotals` CHANGE COLUMN `karmaspent` `karmaspent` int(11) NOT NULL DEFAULT 0 AFTER `karma`;
ALTER TABLE `karmatotals` ADD INDEX(`byondkey`);

ALTER TABLE `watch` CHANGE COLUMN `ckey` `ckey` VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `watch` CHANGE COLUMN `reason` `reason` MEDIUMTEXT COLLATE utf8mb4_unicode_ci NOT NULL AFTER `ckey`;
ALTER TABLE `watch` CHANGE COLUMN `adminckey` `adminckey` VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL AFTER `timestamp`;
ALTER TABLE `watch` CHANGE COLUMN `last_editor` `last_editor` VARCHAR(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `adminckey`;
ALTER TABLE `watch` CHANGE COLUMN `edits` `edits` MEDIUMTEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `last_editor`;

ALTER TABLE `whitelist` CHANGE COLUMN `ckey` `ckey` VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL AFTER `id`;
ALTER TABLE `whitelist` CHANGE COLUMN `job` `job` MEDIUMTEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `ckey`;
ALTER TABLE `whitelist` CHANGE COLUMN `species` `species` MEDIUMTEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `job`;
ALTER TABLE `whitelist` ADD INDEX(`ckey`);


