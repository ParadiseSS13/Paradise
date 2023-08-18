CREATE DATABASE  IF NOT EXISTS `paradise_gamedb` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `paradise_gamedb`;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `characters`
--

DROP TABLE IF EXISTS `characters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `characters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `slot` int(2) NOT NULL,
  `OOC_Notes` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `real_name` varchar(55) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_is_always_random` tinyint(1) NOT NULL,
  `gender` varchar(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `age` smallint(4) NOT NULL,
  `species` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `language` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hair_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000',
  `secondary_hair_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000',
  `facial_hair_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000',
  `secondary_facial_hair_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000',
  `skin_tone` smallint(4) NOT NULL,
  `skin_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000',
  `marking_colours` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'head=%23000000&body=%23000000&tail=%23000000',
  `head_accessory_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000',
  `hair_style_name` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `facial_style_name` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `marking_styles` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'head=None&body=None&tail=None',
  `head_accessory_style_name` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alt_head_name` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `eye_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000',
  `underwear` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `undershirt` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `backbag` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `b_type` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alternate_option` smallint(4) NOT NULL,
  `job_support_high` mediumint(8) NOT NULL,
  `job_support_med` mediumint(8) NOT NULL,
  `job_support_low` mediumint(8) NOT NULL,
  `job_medsci_high` mediumint(8) NOT NULL,
  `job_medsci_med` mediumint(8) NOT NULL,
  `job_medsci_low` mediumint(8) NOT NULL,
  `job_engsec_high` mediumint(8) NOT NULL,
  `job_engsec_med` mediumint(8) NOT NULL,
  `job_engsec_low` mediumint(8) NOT NULL,
  `flavor_text` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `med_record` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `sec_record` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `gen_record` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `disabilities` mediumint(8) NOT NULL,
  `player_alt_titles` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `organ_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `rlimb_data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `nanotrasen_relation` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `speciesprefs` int(1) NOT NULL,
  `socks` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `body_accessory` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `gear` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `autohiss` tinyint(1) NOT NULL,
  `hair_gradient` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hair_gradient_offset` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0,0',
  `hair_gradient_colour` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#000000',
  `hair_gradient_alpha` tinyint(3) UNSIGNED NOT NULL DEFAULT '255',
  `custom_emotes` LONGTEXT COLLATE 'utf8mb4_unicode_ci' DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`)
) ENGINE=InnoDB AUTO_INCREMENT=125467 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customuseritems`
--

DROP TABLE IF EXISTS `customuseritems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customuseritems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cuiCKey` varchar(36) NOT NULL,
  `cuiRealName` varchar(60) NOT NULL,
  `cuiPath` varchar(255) NOT NULL,
  `cuiItemName` text,
  `cuiDescription` text,
  `cuiReason` text,
  `cuiPropAdjust` text,
  `cuiJobMask` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cuiCKey` (`cuiCKey`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `death`
--

DROP TABLE IF EXISTS `death`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `death` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pod` text NOT NULL COMMENT 'Place of death',
  `coord` text NOT NULL COMMENT 'X, Y, Z POD',
  `tod` datetime NOT NULL COMMENT 'Time of death',
  `death_rid` INT NULL,
  `server_id` TEXT NULL DEFAULT NULL,
  `job` text NOT NULL,
  `special` text NOT NULL,
  `name` text NOT NULL,
  `byondkey` text NOT NULL,
  `laname` text NOT NULL COMMENT 'Last attacker name',
  `lakey` text NOT NULL COMMENT 'Last attacker key',
  `gender` text NOT NULL,
  `bruteloss` int(11) NOT NULL,
  `brainloss` int(11) NOT NULL,
  `fireloss` int(11) NOT NULL,
  `oxyloss` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=166546 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `donators`
--

DROP TABLE IF EXISTS `donators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `donators` (
  `patreon_name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tier` int(2),
  `ckey` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Manual Field',
  `start_date` datetime,
  `end_date` datetime,
  `active` boolean,
  PRIMARY KEY (`patreon_name`),
  KEY `ckey` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `admin_rank` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Administrator',
  `level` int(2) NOT NULL DEFAULT '0',
  `flags` int(16) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`)
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `admin_log`
--

DROP TABLE IF EXISTS `admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `adminckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `adminip` varchar(18) COLLATE utf8mb4_unicode_ci NOT NULL,
  `log` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `adminckey` (`adminckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ban`
--

DROP TABLE IF EXISTS `ban`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ban` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `ban_round_id` INT(11) NULL DEFAULT NULL,
  `serverip` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `server_id` VARCHAR(50) NULL DEFAULT NULL COLLATE utf8mb4_general_ci,
  `bantype` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `job` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration` int(11) NOT NULL,
  `rounds` int(11) DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `computerid` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `a_ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `a_computerid` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `a_ip` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `who` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `adminwho` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `edits` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unbanned` tinyint(1) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_round_id` INT(11) NULL DEFAULT NULL,
  `unbanned_ckey` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unbanned_computerid` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unbanned_ip` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `exportable` TINYINT(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`),
  KEY `computerid` (`computerid`),
  KEY `ip` (`ip`),
  KEY `exportable` (`exportable`)
) ENGINE=InnoDB AUTO_INCREMENT=58903 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feedback` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(8) NOT NULL,
  `key_name` varchar(32) NOT NULL,
  `key_type` enum('text', 'amount', 'tally', 'nested tally', 'associative') NOT NULL,
  `version` tinyint(3) UNSIGNED NOT NULL,
  `json` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=257638 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `player`
--

DROP TABLE IF EXISTS `player`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `firstseen` datetime NOT NULL,
  `lastseen` datetime NOT NULL,
  `ip` varchar(18) COLLATE utf8mb4_unicode_ci NOT NULL,
  `computerid` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastadminrank` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Player',
  `ooccolor` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT '#b82e00',
  `UI_style` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT 'Midnight',
  `UI_style_color` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT '#ffffff',
  `UI_style_alpha` smallint(4) DEFAULT '255',
  `be_role` LONGTEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `default_slot` smallint(4) DEFAULT '1',
  `toggles` int(11) DEFAULT NULL,
  `toggles_2` int(11) DEFAULT NULL,
  `sound` mediumint(8) DEFAULT '31',
  `volume_mixer` LONGTEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lastchangelog` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `exp` LONGTEXT COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `clientfps` smallint(4) DEFAULT '63',
  `atklog` smallint(4) DEFAULT '0',
  `fuid` bigint(20) DEFAULT NULL,
  `fupdate` smallint(4) DEFAULT '0',
  `parallax` tinyint(1) DEFAULT '8',
  `byond_date` DATE DEFAULT NULL,
  `2fa_status` ENUM('DISABLED','ENABLED_IP','ENABLED_ALWAYS') NOT NULL DEFAULT 'DISABLED' COLLATE 'utf8mb4_general_ci',
  `screentip_mode` tinyint(1) DEFAULT '8',
  `screentip_color` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#ffd391',
  `ghost_darkness_level` tinyint(1) UNSIGNED NOT NULL DEFAULT '255',
  `colourblind_mode` VARCHAR(48) NOT NULL DEFAULT 'None' COLLATE 'utf8mb4_general_ci',
  `keybindings` LONGTEXT COLLATE 'utf8mb4_unicode_ci' DEFAULT NULL,
  `server_region` VARCHAR(32) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
  `muted_adminsounds_ckeys` MEDIUMTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
  `viewrange` VARCHAR(5) NOT NULL DEFAULT '19x15' COLLATE 'utf8mb4_general_ci',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`),
  KEY `lastseen` (`lastseen`),
  KEY `computerid` (`computerid`),
  KEY `ip` (`ip`),
  KEY `fuid` (`fuid`),
  KEY `fupdate` (`fupdate`)
) ENGINE=InnoDB AUTO_INCREMENT=135298 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `privacy`
--

DROP TABLE IF EXISTS `privacy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `privacy` (
  `ckey` varchar(32) NOT NULL,
  `datetime` datetime NOT NULL,
  `consent` bit(1) NOT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `library`
--

DROP TABLE IF EXISTS `library`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `library` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`author` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`title` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`content` MEDIUMTEXT NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`ckey` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_unicode_ci',
	`reports` MEDIUMTEXT NOT NULL COLLATE 'utf8mb3_general_ci',
	`summary` MEDIUMTEXT NOT NULL COLLATE 'utf8mb3_general_ci',
	`rating` DOUBLE NULL DEFAULT '0',
	`raters` MEDIUMTEXT NOT NULL COLLATE 'utf8mb3_general_ci',
	`primary_category` INT(11) NULL DEFAULT '0',
	`secondary_category` INT(11) NOT NULL DEFAULT '0',
	`tertiary_category` INT(11) NULL DEFAULT '0',
	PRIMARY KEY (`id`) USING BTREE,
	INDEX `ckey` (`ckey`) USING BTREE,
	INDEX `flagged` (`reports`(1024)) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `legacy_population`
--

DROP TABLE IF EXISTS `legacy_population`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `legacy_population` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playercount` int(11) DEFAULT NULL,
  `admincount` int(11) DEFAULT NULL,
  `server_id` VARCHAR(50) NULL DEFAULT NULL,
  `time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2550 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `watch`
--

DROP TABLE IF EXISTS `watch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `watch` (
  `ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` datetime NOT NULL,
  `adminckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_editor` varchar(32) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `edits` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `notes`
--

DROP TABLE IF EXISTS `notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `notetext` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `round_id` INT(11) NULL DEFAULT NULL,
  `adminckey` varchar(32) NOT NULL,
  `last_editor` varchar(32),
  `edits` text,
  `server` varchar(50) NOT NULL,
  `crew_playtime` mediumint(8) UNSIGNED DEFAULT '0',
  `automated` TINYINT(3) UNSIGNED NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `memo`
--

DROP TABLE IF EXISTS `memo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `memo` (
  `ckey` varchar(32) NOT NULL,
  `memotext` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `last_editor` varchar(32),
  `edits` text,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ipintel`
--
DROP TABLE IF EXISTS `ipintel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE  `ipintel` (
  `ip` int UNSIGNED NOT NULL,
  `date` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
  `intel` real NOT NULL DEFAULT '0',
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vpn_whitelist`
--
DROP TABLE IF EXISTS `vpn_whitelist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vpn_whitelist` (
  `ckey` varchar(32) NOT NULL,
  `reason` text,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oauth_tokens`
--
DROP TABLE IF EXISTS `oauth_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_tokens` (
  `ckey` varchar(32) NOT NULL,
  `token` varchar(32) NOT NULL,
  PRIMARY KEY (`token`),
  KEY `ckey` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Table structure for table `playtime_history`
--
DROP TABLE IF EXISTS `playtime_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `playtime_history` (
  `ckey` varchar(32) NOT NULL,
  `date` DATE NOT NULL,
  `time_living` SMALLINT NOT NULL,
  `time_ghost` SMALLINT NOT NULL,
  PRIMARY KEY (`ckey`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Table structure for table `connection_log`
--
DROP TABLE IF EXISTS `connection_log`;
CREATE TABLE `connection_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` varchar(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `server_id` VARCHAR(50) NULL DEFAULT NULL,
  `result` ENUM('ESTABLISHED','DROPPED - IPINTEL','DROPPED - BANNED','DROPPED - INVALID') NOT NULL DEFAULT 'ESTABLISHED' COLLATE 'utf8mb4_general_ci',
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`),
  KEY `ip` (`ip`),
  KEY `computerid` (`computerid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `changelog`
--
DROP TABLE IF EXISTS `changelog`;
CREATE TABLE `changelog` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`pr_number` INT(11) NOT NULL,
	`date_merged` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	`author` VARCHAR(32) NOT NULL,
	`cl_type` ENUM('FIX','WIP','TWEAK','SOUNDADD','SOUNDDEL','CODEADD','CODEDEL','IMAGEADD','IMAGEDEL','SPELLCHECK','EXPERIMENT') NOT NULL,
	`cl_entry` TEXT NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `ip2group`
--
DROP TABLE IF EXISTS `ip2group`;
CREATE TABLE `ip2group` (
  `ip` varchar (18) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
  `groupstr` varchar (32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`ip`),
  KEY `groupstr` (`groupstr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `round`
--
DROP TABLE IF EXISTS `round`;
CREATE TABLE `round` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `initialize_datetime` DATETIME NOT NULL,
  `start_datetime` DATETIME NULL,
  `shutdown_datetime` DATETIME NULL,
  `end_datetime` DATETIME NULL,
  `server_ip` INT(10) UNSIGNED NOT NULL,
  `server_port` SMALLINT(5) UNSIGNED NOT NULL,
  `commit_hash` CHAR(40) NULL,
  `game_mode` VARCHAR(32) NULL,
  `game_mode_result` VARCHAR(64) NULL,
  `end_state` VARCHAR(64) NULL,
  `shuttle_name` VARCHAR(64) NULL,
  `map_name` VARCHAR(32) NULL,
  `station_name` VARCHAR(80) NULL,
  `server_id` VARCHAR(50) NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--
-- Table structure for table `2fa_secrets`
--
DROP TABLE IF EXISTS `2fa_secrets`;
CREATE TABLE `2fa_secrets` (
	`ckey` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`secret` VARCHAR(64) NOT NULL COLLATE 'utf8mb4_general_ci',
	`date_setup` DATETIME NOT NULL DEFAULT current_timestamp(),
	`last_time` DATETIME NULL DEFAULT NULL,
	PRIMARY KEY (`ckey`) USING BTREE
) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;

--
-- Table structure for table `pai_saves`
--
DROP TABLE IF EXISTS `pai_saves`;
CREATE TABLE `pai_saves` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`ckey` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`pai_name` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`description` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`preferred_role` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`ooc_comments` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `ckey` (`ckey`) USING BTREE
) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;

--
-- Table structure for table `instance_data_cache`
--
DROP TABLE IF EXISTS `instance_data_cache`;
CREATE TABLE `instance_data_cache` (
	`server_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`key_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`key_value` VARCHAR(12345) NOT NULL COLLATE 'utf8mb4_general_ci',
	`last_updated` TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	PRIMARY KEY (`server_id`, `key_name`) USING HASH
) COLLATE='utf8mb4_general_ci' ENGINE=MEMORY;

--
-- Table structure for table `tickets`
--
DROP TABLE IF EXISTS `tickets`;
CREATE TABLE `tickets` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`ticket_num` INT(11) NOT NULL,
	`ticket_type` ENUM('ADMIN','MENTOR') NOT NULL COLLATE 'utf8mb4_general_ci',
	`real_filetime` DATETIME NOT NULL,
	`relative_filetime` TIME NOT NULL,
	`ticket_creator` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
	`ticket_topic` TEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`ticket_taker` VARCHAR(32) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`ticket_take_time` DATETIME NULL DEFAULT NULL,
	`all_responses` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`awho` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
	`end_round_state` ENUM('OPEN','CLOSED','RESOLVED','STALE','UNKNOWN') NOT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`id`) USING BTREE,
	CONSTRAINT `all_responses` CHECK (json_valid(`all_responses`)),
	CONSTRAINT `awho` CHECK (json_valid(`awho`))
) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;
