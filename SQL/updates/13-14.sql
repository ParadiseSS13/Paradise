#Updating the SQL from version 13 to version 14. -Kyet


# Add new tables used by backend tooling

CREATE TABLE `ip2group` (
  `ip` varchar (18) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
  `groupstr` varchar (32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`ip`),
  KEY `groupstr` (`groupstr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



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


# Alter whitelist table to change ckey format to avoid SQL failures when downstreams apply indexes

ALTER TABLE `whitelist` CHANGE COLUMN `ckey` `ckey` VARCHAR(32) COLLATE utf8mb4_unicode_ci NOT NULL AFTER `id`;

# Alter library table to standardize ckey field length

ALTER TABLE `library` CHANGE COLUMN `ckey` `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL AFTER `category`;


# Delete pointless indexes (there is already an index on ckey, having a second index on the exact same data is pointless)

DROP INDEX ckey_UNIQUE ON privacy;



# Add player table field that AA plans to use very soon to store byond account creation date

ALTER TABLE `player` ADD COLUMN `byond_date` DATE DEFAULT NULL;


# **************** READ THIS CAREFULLY **********************************************************
# These updates change your DB to match what we (Paradise) ALREADY USE IN PRODUCTION.
# We (Paradise) do NOT need to run any of these.
# They are included here only for the convenience of github contributors, and downstream servers.

ALTER TABLE `admin` CHANGE COLUMN `ckey` `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `admin` CHANGE COLUMN `rank` `rank` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Administrator';

ALTER TABLE `admin_log` CHANGE COLUMN `adminckey` `adminckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `admin_log` CHANGE COLUMN `adminip` `adminip` varchar(18) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `admin_log` CHANGE COLUMN `log` `log` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL;

ALTER TABLE `characters` CHANGE COLUMN `ckey` `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `OOC_Notes` `OOC_Notes` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `real_name` `real_name` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `gender` `gender` varchar(11) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `species` `species` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `language` `language` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `hair_colour` `hair_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000';
ALTER TABLE `characters` CHANGE COLUMN `secondary_hair_colour` `secondary_hair_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000';
ALTER TABLE `characters` CHANGE COLUMN `facial_hair_colour` `facial_hair_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000';
ALTER TABLE `characters` CHANGE COLUMN `secondary_facial_hair_colour` `secondary_facial_hair_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000';
ALTER TABLE `characters` CHANGE COLUMN `skin_colour` `skin_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000';
ALTER TABLE `characters` CHANGE COLUMN `marking_colours` `marking_colours` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'head=%23000000&body=%23000000&tail=%23000000';
ALTER TABLE `characters` CHANGE COLUMN `head_accessory_colour` `head_accessory_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000';
ALTER TABLE `characters` CHANGE COLUMN `hair_style_name` `hair_style_name` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `facial_style_name` `facial_style_name` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `marking_styles` `marking_styles` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'head=None&body=None&tail=None';
ALTER TABLE `characters` CHANGE COLUMN `head_accessory_style_name` `head_accessory_style_name` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `alt_head_name` `alt_head_name` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `eye_colour` `eye_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000';
ALTER TABLE `characters` CHANGE COLUMN `underwear` `underwear` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `undershirt` `undershirt` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `backbag` `backbag` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL;
ALTER TABLE `characters` CHANGE COLUMN `b_type` `b_type` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `flavor_text` `flavor_text` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `med_record` `med_record` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `sec_record` `sec_record` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `gen_record` `gen_record` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `player_alt_titles` `player_alt_titles` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `organ_data` `organ_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `rlimb_data` `rlimb_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `nanotrasen_relation` `nanotrasen_relation` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `socks` `socks` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `body_accessory` `body_accessory` longtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `characters` CHANGE COLUMN `gear` `gear` longtext COLLATE utf8mb4_unicode_ci NOT NULL;

ALTER TABLE `characters` ADD INDEX(`ckey`);

ALTER TABLE `ban` CHANGE COLUMN `serverip` `serverip` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `ban` CHANGE COLUMN `bantype` `bantype` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `ban` CHANGE COLUMN `reason` `reason` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `ban` CHANGE COLUMN `job` `job` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL;
ALTER TABLE `ban` CHANGE COLUMN `ckey` `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `ban` CHANGE COLUMN `computerid` `computerid` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `ban` CHANGE COLUMN `ip` `ip` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `ban` CHANGE COLUMN `a_ckey` `a_ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `ban` CHANGE COLUMN `a_computerid` `a_computerid` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `ban` CHANGE COLUMN `a_ip` `a_ip` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `ban` CHANGE COLUMN `who` `who` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `ban` CHANGE COLUMN `adminwho` `adminwho` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `ban` CHANGE COLUMN `edits` `edits` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL;
ALTER TABLE `ban` CHANGE COLUMN `unbanned_ckey` `unbanned_ckey` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL;
ALTER TABLE `ban` CHANGE COLUMN `unbanned_computerid` `unbanned_computerid` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL;
ALTER TABLE `ban` CHANGE COLUMN `unbanned_ip` `unbanned_ip` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL;
ALTER TABLE `ban` ADD INDEX(`ckey`);
ALTER TABLE `ban` ADD INDEX(`computerid`);
ALTER TABLE `ban` ADD INDEX(`ip`);

ALTER TABLE `donators` CHANGE COLUMN `patreon_name` `patreon_name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL;
ALTER TABLE `donators` CHANGE COLUMN `ckey` `ckey` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Manual Field';

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

ALTER TABLE `whitelist` CHANGE COLUMN `job` `job` MEDIUMTEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `ckey`;
ALTER TABLE `whitelist` CHANGE COLUMN `species` `species` MEDIUMTEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `job`;
ALTER TABLE `whitelist` ADD INDEX(`ckey`);


