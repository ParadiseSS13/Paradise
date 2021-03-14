# This file is revision 0 of the server SQL schema
# It is intended ONLY for CI testing, and thus has data thrown in to test all update files with
# DO NOT SET THIS AS THE GAMES PROPER SCHEMA OR A LOT OF STUFF WILL BREAK

-- --------------------------------------------------------
-- Host:                         AA07-S-SQL
-- Server version:               10.3.22-MariaDB-0ubuntu0.19.10.1 - Ubuntu 19.10
-- Server OS:                    debian-linux-gnu
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for feedback
DROP DATABASE IF EXISTS `feedback`;
CREATE DATABASE IF NOT EXISTS `feedback` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `feedback`;

-- Dumping structure for table feedback.admin
DROP TABLE IF EXISTS `admin`;
CREATE TABLE IF NOT EXISTS `admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `rank` varchar(32) NOT NULL DEFAULT 'Administrator',
  `level` int(2) NOT NULL DEFAULT 0,
  `flags` int(16) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.admin: ~0 rows (approximately)
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` (`id`, `ckey`, `rank`, `level`, `flags`) VALUES
	(1, 'AffectedArc07', 'Administrator', 0, 131071);
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;

-- Dumping structure for table feedback.admin_log
DROP TABLE IF EXISTS `admin_log`;
CREATE TABLE IF NOT EXISTS `admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `adminip` varchar(18) NOT NULL,
  `log` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.admin_log: ~0 rows (approximately)
/*!40000 ALTER TABLE `admin_log` DISABLE KEYS */;
INSERT INTO `admin_log` (`id`, `datetime`, `adminckey`, `adminip`, `log`) VALUES
	(1, '2020-04-24 17:36:49', 'AffectedArc07', '127.0.0.1', 'Created this row');
/*!40000 ALTER TABLE `admin_log` ENABLE KEYS */;

-- Dumping structure for table feedback.ban
DROP TABLE IF EXISTS `ban`;
CREATE TABLE IF NOT EXISTS `ban` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `serverip` varchar(32) NOT NULL,
  `bantype` varchar(32) NOT NULL,
  `reason` text NOT NULL,
  `job` varchar(32) DEFAULT NULL,
  `duration` int(11) NOT NULL,
  `rounds` int(11) DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `ip` varchar(32) NOT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `a_ip` varchar(32) NOT NULL,
  `who` text NOT NULL,
  `adminwho` text NOT NULL,
  `edits` text DEFAULT NULL,
  `unbanned` tinyint(1) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_ip` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.ban: ~0 rows (approximately)
/*!40000 ALTER TABLE `ban` DISABLE KEYS */;
INSERT INTO `ban` (`id`, `bantime`, `serverip`, `bantype`, `reason`, `job`, `duration`, `rounds`, `expiration_time`, `ckey`, `computerid`, `ip`, `a_ckey`, `a_computerid`, `a_ip`, `who`, `adminwho`, `edits`, `unbanned`, `unbanned_datetime`, `unbanned_ckey`, `unbanned_computerid`, `unbanned_ip`) VALUES
	(1, '2020-04-24 17:40:05', '127.0.0.1', 'PERMABAN', 'Breaking it all', NULL, -1, NULL, '2020-04-24 17:40:20', 'AffectedArc07', '1111111111', '127.0.0.1', 'AffectedArc07', '1111111111', '127.0.0.1', 'Player1, Player2, Whoever', 'SomeAdmin', NULL, NULL, NULL, NULL, NULL, NULL);
/*!40000 ALTER TABLE `ban` ENABLE KEYS */;

-- Dumping structure for table feedback.characters
DROP TABLE IF EXISTS `characters`;
CREATE TABLE IF NOT EXISTS `characters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `slot` int(2) NOT NULL,
  `OOC_Notes` mediumtext NOT NULL,
  `real_name` varchar(45) NOT NULL,
  `name_is_always_random` tinyint(1) NOT NULL,
  `gender` varchar(11) NOT NULL,
  `age` smallint(4) NOT NULL,
  `species` varchar(45) NOT NULL,
  `language` varchar(45) NOT NULL,
  `hair_red` smallint(4) NOT NULL,
  `hair_green` smallint(4) NOT NULL,
  `hair_blue` smallint(4) NOT NULL,
  `secondary_hair_red` smallint(4) NOT NULL,
  `secondary_hair_green` smallint(4) NOT NULL,
  `secondary_hair_blue` smallint(4) NOT NULL,
  `facial_red` smallint(4) NOT NULL,
  `facial_green` smallint(4) NOT NULL,
  `facial_blue` smallint(4) NOT NULL,
  `secondary_facial_red` smallint(4) NOT NULL,
  `secondary_facial_green` smallint(4) NOT NULL,
  `secondary_facial_blue` smallint(4) NOT NULL,
  `skin_tone` smallint(4) NOT NULL,
  `skin_red` smallint(4) NOT NULL,
  `skin_green` smallint(4) NOT NULL,
  `skin_blue` smallint(4) NOT NULL,
  `marking_colours` varchar(255) NOT NULL DEFAULT 'head=%23000000&body=%23000000&tail=%23000000',
  `head_accessory_red` smallint(4) NOT NULL,
  `head_accessory_green` smallint(4) NOT NULL,
  `head_accessory_blue` smallint(4) NOT NULL,
  `hair_style_name` varchar(45) NOT NULL,
  `facial_style_name` varchar(45) NOT NULL,
  `marking_styles` varchar(255) NOT NULL DEFAULT 'head=None&body=None&tail=None',
  `head_accessory_style_name` varchar(45) NOT NULL,
  `alt_head_name` varchar(45) NOT NULL,
  `eyes_red` smallint(4) NOT NULL,
  `eyes_green` smallint(4) NOT NULL,
  `eyes_blue` smallint(4) NOT NULL,
  `underwear` mediumtext NOT NULL,
  `undershirt` mediumtext NOT NULL,
  `backbag` mediumtext NOT NULL,
  `b_type` varchar(45) NOT NULL,
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
  `job_karma_high` mediumint(8) NOT NULL,
  `job_karma_med` mediumint(8) NOT NULL,
  `job_karma_low` mediumint(8) NOT NULL,
  `flavor_text` mediumtext NOT NULL,
  `med_record` mediumtext NOT NULL,
  `sec_record` mediumtext NOT NULL,
  `gen_record` mediumtext NOT NULL,
  `disabilities` mediumint(8) NOT NULL,
  `player_alt_titles` mediumtext NOT NULL,
  `organ_data` mediumtext NOT NULL,
  `rlimb_data` mediumtext NOT NULL,
  `nanotrasen_relation` varchar(45) NOT NULL,
  `speciesprefs` int(1) NOT NULL,
  `socks` mediumtext NOT NULL,
  `body_accessory` mediumtext NOT NULL,
  `gear` mediumtext NOT NULL,
  `autohiss` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Dumping data for table feedback.characters: ~0 rows (approximately)
/*!40000 ALTER TABLE `characters` DISABLE KEYS */;
INSERT INTO `characters` (`id`, `ckey`, `slot`, `OOC_Notes`, `real_name`, `name_is_always_random`, `gender`, `age`, `species`, `language`, `hair_red`, `hair_green`, `hair_blue`, `secondary_hair_red`, `secondary_hair_green`, `secondary_hair_blue`, `facial_red`, `facial_green`, `facial_blue`, `secondary_facial_red`, `secondary_facial_green`, `secondary_facial_blue`, `skin_tone`, `skin_red`, `skin_green`, `skin_blue`, `marking_colours`, `head_accessory_red`, `head_accessory_green`, `head_accessory_blue`, `hair_style_name`, `facial_style_name`, `marking_styles`, `head_accessory_style_name`, `alt_head_name`, `eyes_red`, `eyes_green`, `eyes_blue`, `underwear`, `undershirt`, `backbag`, `b_type`, `alternate_option`, `job_support_high`, `job_support_med`, `job_support_low`, `job_medsci_high`, `job_medsci_med`, `job_medsci_low`, `job_engsec_high`, `job_engsec_med`, `job_engsec_low`, `job_karma_high`, `job_karma_med`, `job_karma_low`, `flavor_text`, `med_record`, `sec_record`, `gen_record`, `disabilities`, `player_alt_titles`, `organ_data`, `rlimb_data`, `nanotrasen_relation`, `speciesprefs`, `socks`, `body_accessory`, `gear`, `autohiss`) VALUES
	(1, 'AffectedArc07', 1, 'Some notes', 'John Smith', 0, 'male', 25, 'Human', 'None', 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 25, 10, 10, 10, 'head=%23000000&body=%23000000&tail=%23000000', 10, 10, 10, 'Bald', 'Shaved', 'head=None&body=None&tail=None', 'None', 'None', 10, 10, 10, 'Nude', 'Nude', 'Grey Backpack', 'A+', 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'He is short', 'Yes', 'Yes', 'Yes', 0, ' ', ' ', ' ', 'Neutral', 0, 'Nude', ' ', ' ', 0);
/*!40000 ALTER TABLE `characters` ENABLE KEYS */;

-- Dumping structure for table feedback.customuseritems
DROP TABLE IF EXISTS `customuseritems`;
CREATE TABLE IF NOT EXISTS `customuseritems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cuiCKey` varchar(36) NOT NULL,
  `cuiRealName` varchar(60) NOT NULL,
  `cuiPath` varchar(255) NOT NULL,
  `cuiItemName` text DEFAULT NULL,
  `cuiDescription` text DEFAULT NULL,
  `cuiReason` text DEFAULT NULL,
  `cuiPropAdjust` text DEFAULT NULL,
  `cuiJobMask` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.customuseritems: 0 rows
/*!40000 ALTER TABLE `customuseritems` DISABLE KEYS */;
INSERT INTO `customuseritems` (`id`, `cuiCKey`, `cuiRealName`, `cuiPath`, `cuiItemName`, `cuiDescription`, `cuiReason`, `cuiPropAdjust`, `cuiJobMask`) VALUES
	(1, 'AffectedArc07', 'Character Name', '/obj/item/multitool', NULL, NULL, NULL, NULL, '*');
/*!40000 ALTER TABLE `customuseritems` ENABLE KEYS */;

-- Dumping structure for table feedback.death
DROP TABLE IF EXISTS `death`;
CREATE TABLE IF NOT EXISTS `death` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pod` text NOT NULL COMMENT 'Place of death',
  `coord` text NOT NULL COMMENT 'X, Y, Z POD',
  `tod` datetime NOT NULL COMMENT 'Time of death',
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
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.death: 0 rows
/*!40000 ALTER TABLE `death` DISABLE KEYS */;
INSERT INTO `death` (`id`, `pod`, `coord`, `tod`, `job`, `special`, `name`, `byondkey`, `laname`, `lakey`, `gender`, `bruteloss`, `brainloss`, `fireloss`, `oxyloss`) VALUES
	(1, 'Central Primary Hallway', '1,1,1', '2020-04-24 17:58:41', 'Captain', 'Traitor', 'John Smith', 'AffectedArc07', 'Bad Man', 'BadGuyCkey', 'Male', 12, 12, 12, 12);
/*!40000 ALTER TABLE `death` ENABLE KEYS */;

-- Dumping structure for table feedback.donators
DROP TABLE IF EXISTS `donators`;
CREATE TABLE IF NOT EXISTS `donators` (
  `patreon_name` varchar(32) NOT NULL,
  `tier` int(2) DEFAULT NULL,
  `ckey` varchar(32) DEFAULT NULL COMMENT 'Manual Field',
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`patreon_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table feedback.donators: ~0 rows (approximately)
/*!40000 ALTER TABLE `donators` DISABLE KEYS */;
INSERT INTO `donators` (`patreon_name`, `tier`, `ckey`, `start_date`, `end_date`, `active`) VALUES
	('AffectedArc07', 3, 'AffectedArc07', '2020-04-24 18:00:47', '2020-04-24 18:00:48', 1);
/*!40000 ALTER TABLE `donators` ENABLE KEYS */;

-- Dumping structure for table feedback.feedback
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE IF NOT EXISTS `feedback` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime NOT NULL,
  `round_id` int(8) NOT NULL,
  `var_name` varchar(32) NOT NULL,
  `var_value` int(16) DEFAULT NULL,
  `details` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.feedback: 0 rows
/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
INSERT INTO `feedback` (`id`, `time`, `round_id`, `var_name`, `var_value`, `details`) VALUES
	(1, '2020-04-24 18:01:08', 1, 'yes', 1, 'feedback scares me');
/*!40000 ALTER TABLE `feedback` ENABLE KEYS */;

-- Dumping structure for table feedback.karma
DROP TABLE IF EXISTS `karma`;
CREATE TABLE IF NOT EXISTS `karma` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `spendername` text NOT NULL,
  `spenderkey` text NOT NULL,
  `receivername` text NOT NULL,
  `receiverkey` text NOT NULL,
  `receiverrole` text DEFAULT NULL,
  `receiverspecial` text DEFAULT NULL,
  `isnegative` tinyint(1) DEFAULT NULL,
  `spenderip` text NOT NULL,
  `time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.karma: 0 rows
/*!40000 ALTER TABLE `karma` DISABLE KEYS */;
INSERT INTO `karma` (`id`, `spendername`, `spenderkey`, `receivername`, `receiverkey`, `receiverrole`, `receiverspecial`, `isnegative`, `spenderip`, `time`) VALUES
	(1, 'John Smith', 'AffectedArc07', 'Other Man', 'OtherCkey', 'Captain', 'Special', 0, '127.0.0.1', '2020-04-24 18:02:00');
/*!40000 ALTER TABLE `karma` ENABLE KEYS */;

-- Dumping structure for table feedback.karmatotals
DROP TABLE IF EXISTS `karmatotals`;
CREATE TABLE IF NOT EXISTS `karmatotals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `byondkey` text NOT NULL,
  `karma` int(11) NOT NULL,
  `karmaspent` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.karmatotals: 0 rows
/*!40000 ALTER TABLE `karmatotals` DISABLE KEYS */;
INSERT INTO `karmatotals` (`id`, `byondkey`, `karma`, `karmaspent`) VALUES
	(1, 'AffectedArc07', 1000, 100);
/*!40000 ALTER TABLE `karmatotals` ENABLE KEYS */;

-- Dumping structure for table feedback.legacy_population
DROP TABLE IF EXISTS `legacy_population`;
CREATE TABLE IF NOT EXISTS `legacy_population` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playercount` int(11) DEFAULT NULL,
  `admincount` int(11) DEFAULT NULL,
  `time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.legacy_population: 0 rows
/*!40000 ALTER TABLE `legacy_population` DISABLE KEYS */;
INSERT INTO `legacy_population` (`id`, `playercount`, `admincount`, `time`) VALUES
	(1, 233, 23, '2020-04-24 18:02:19');
/*!40000 ALTER TABLE `legacy_population` ENABLE KEYS */;

-- Dumping structure for table feedback.library
DROP TABLE IF EXISTS `library`;
CREATE TABLE IF NOT EXISTS `library` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` text NOT NULL,
  `title` text NOT NULL,
  `content` text NOT NULL,
  `category` text NOT NULL,
  `ckey` varchar(45) NOT NULL,
  `flagged` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.library: 0 rows
/*!40000 ALTER TABLE `library` DISABLE KEYS */;
INSERT INTO `library` (`id`, `author`, `title`, `content`, `category`, `ckey`, `flagged`) VALUES
	(1, 'John Smith', 'A book', 'WOW WHAT A BOOK', 'Fiction', 'AffectedArc07', 0);
/*!40000 ALTER TABLE `library` ENABLE KEYS */;

-- Dumping structure for table feedback.memo
DROP TABLE IF EXISTS `memo`;
CREATE TABLE IF NOT EXISTS `memo` (
  `ckey` varchar(32) NOT NULL,
  `memotext` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` text DEFAULT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.memo: ~0 rows (approximately)
/*!40000 ALTER TABLE `memo` DISABLE KEYS */;
INSERT INTO `memo` (`ckey`, `memotext`, `timestamp`, `last_editor`, `edits`) VALUES
	('AffectedArc07', 'Remember to test your PRs', '2020-04-24 18:04:00', NULL, NULL);
/*!40000 ALTER TABLE `memo` ENABLE KEYS */;

-- Dumping structure for table feedback.notes
DROP TABLE IF EXISTS `notes`;
CREATE TABLE IF NOT EXISTS `notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `notetext` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` text DEFAULT NULL,
  `server` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.notes: ~0 rows (approximately)
/*!40000 ALTER TABLE `notes` DISABLE KEYS */;
INSERT INTO `notes` (`id`, `ckey`, `notetext`, `timestamp`, `adminckey`, `last_editor`, `edits`, `server`) VALUES
	(1, 'AffectedArc07', 'Cant behave', '2020-04-24 18:04:14', 'AffectedArc07', NULL, NULL, 'SS13');
/*!40000 ALTER TABLE `notes` ENABLE KEYS */;

-- Dumping structure for table feedback.player
DROP TABLE IF EXISTS `player`;
CREATE TABLE IF NOT EXISTS `player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) NOT NULL,
  `firstseen` datetime NOT NULL,
  `lastseen` datetime NOT NULL,
  `ip` varchar(18) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `lastadminrank` varchar(32) NOT NULL DEFAULT 'Player',
  `ooccolor` varchar(7) DEFAULT '#b82e00',
  `UI_style` varchar(10) DEFAULT 'Midnight',
  `UI_style_color` varchar(7) DEFAULT '#ffffff',
  `UI_style_alpha` smallint(4) DEFAULT 255,
  `be_role` mediumtext DEFAULT NULL,
  `default_slot` smallint(4) DEFAULT 1,
  `toggles` mediumint(8) DEFAULT 383,
  `sound` mediumint(8) DEFAULT 31,
  `randomslot` tinyint(1) DEFAULT 0,
  `volume` smallint(4) DEFAULT 100,
  `nanoui_fancy` smallint(4) DEFAULT 1,
  `show_ghostitem_attack` smallint(4) DEFAULT 1,
  `lastchangelog` varchar(32) NOT NULL DEFAULT '0',
  `windowflashing` smallint(4) DEFAULT 1,
  `ghost_anonsay` tinyint(1) NOT NULL DEFAULT 0,
  `exp` mediumtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.player: ~0 rows (approximately)
/*!40000 ALTER TABLE `player` DISABLE KEYS */;
INSERT INTO `player` (`id`, `ckey`, `firstseen`, `lastseen`, `ip`, `computerid`, `lastadminrank`, `ooccolor`, `UI_style`, `UI_style_color`, `UI_style_alpha`, `be_role`, `default_slot`, `toggles`, `sound`, `randomslot`, `volume`, `nanoui_fancy`, `show_ghostitem_attack`, `lastchangelog`, `windowflashing`, `ghost_anonsay`, `exp`) VALUES
	(1, 'AffectedArc07', '2020-04-24 18:04:44', '2020-04-24 18:04:45', '127.0.0.1', '1111111111', 'Player', '#b82e00', 'Midnight', '#ffffff', 10, NULL, 1, 1024, 16, 0, 100, 1, 1, '0', 1, 1, NULL);
/*!40000 ALTER TABLE `player` ENABLE KEYS */;

-- Dumping structure for table feedback.poll_option
DROP TABLE IF EXISTS `poll_option`;
CREATE TABLE IF NOT EXISTS `poll_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pollid` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `percentagecalc` tinyint(1) NOT NULL DEFAULT 1,
  `minval` int(3) DEFAULT NULL,
  `maxval` int(3) DEFAULT NULL,
  `descmin` varchar(32) DEFAULT NULL,
  `descmid` varchar(32) DEFAULT NULL,
  `descmax` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.poll_option: ~0 rows (approximately)
/*!40000 ALTER TABLE `poll_option` DISABLE KEYS */;
INSERT INTO `poll_option` (`id`, `pollid`, `text`, `percentagecalc`, `minval`, `maxval`, `descmin`, `descmid`, `descmax`) VALUES
	(1, 1, 'What is this', 12, NULL, NULL, NULL, NULL, NULL);
/*!40000 ALTER TABLE `poll_option` ENABLE KEYS */;

-- Dumping structure for table feedback.poll_question
DROP TABLE IF EXISTS `poll_question`;
CREATE TABLE IF NOT EXISTS `poll_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `polltype` varchar(16) NOT NULL DEFAULT 'OPTION',
  `starttime` datetime NOT NULL,
  `endtime` datetime NOT NULL,
  `question` varchar(255) NOT NULL,
  `adminonly` tinyint(1) DEFAULT 0,
  `multiplechoiceoptions` int(2) DEFAULT NULL,
  `createdby_ckey` varchar(45) DEFAULT NULL,
  `createdby_ip` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.poll_question: ~0 rows (approximately)
/*!40000 ALTER TABLE `poll_question` DISABLE KEYS */;
INSERT INTO `poll_question` (`id`, `polltype`, `starttime`, `endtime`, `question`, `adminonly`, `multiplechoiceoptions`, `createdby_ckey`, `createdby_ip`) VALUES
	(1, 'OPTION', '2020-04-24 18:05:31', '2020-04-24 18:05:33', 'Is this a good idea', 0, NULL, NULL, NULL);
/*!40000 ALTER TABLE `poll_question` ENABLE KEYS */;

-- Dumping structure for table feedback.poll_textreply
DROP TABLE IF EXISTS `poll_textreply`;
CREATE TABLE IF NOT EXISTS `poll_textreply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` varchar(18) NOT NULL,
  `replytext` text NOT NULL,
  `adminrank` varchar(32) NOT NULL DEFAULT 'Player',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.poll_textreply: ~0 rows (approximately)
/*!40000 ALTER TABLE `poll_textreply` DISABLE KEYS */;
INSERT INTO `poll_textreply` (`id`, `datetime`, `pollid`, `ckey`, `ip`, `replytext`, `adminrank`) VALUES
	(1, '2020-04-24 18:05:42', 1, 'AffectedArc07', '127.0.0.1', 'This is far too much work for a CI rework', 'Player');
/*!40000 ALTER TABLE `poll_textreply` ENABLE KEYS */;

-- Dumping structure for table feedback.poll_vote
DROP TABLE IF EXISTS `poll_vote`;
CREATE TABLE IF NOT EXISTS `poll_vote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `optionid` int(11) NOT NULL,
  `ckey` varchar(255) NOT NULL,
  `ip` varchar(16) NOT NULL,
  `adminrank` varchar(32) NOT NULL,
  `rating` int(2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.poll_vote: ~0 rows (approximately)
/*!40000 ALTER TABLE `poll_vote` DISABLE KEYS */;
INSERT INTO `poll_vote` (`id`, `datetime`, `pollid`, `optionid`, `ckey`, `ip`, `adminrank`, `rating`) VALUES
	(1, '2020-04-24 18:06:02', 1, 1, 'AffectedArc07', '127.0.0.1', 'Administrator', NULL);
/*!40000 ALTER TABLE `poll_vote` ENABLE KEYS */;

-- Dumping structure for table feedback.privacy
DROP TABLE IF EXISTS `privacy`;
CREATE TABLE IF NOT EXISTS `privacy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `option` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.privacy: ~0 rows (approximately)
/*!40000 ALTER TABLE `privacy` DISABLE KEYS */;
INSERT INTO `privacy` (`id`, `datetime`, `ckey`, `option`) VALUES
	(1, '2020-04-24 18:06:20', 'AffectedArc07', '1');
/*!40000 ALTER TABLE `privacy` ENABLE KEYS */;

-- Dumping structure for table feedback.watch
DROP TABLE IF EXISTS `watch`;
CREATE TABLE IF NOT EXISTS `watch` (
  `ckey` varchar(32) NOT NULL,
  `reason` text NOT NULL,
  `timestamp` datetime NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `last_editor` varchar(32) DEFAULT NULL,
  `edits` text DEFAULT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.watch: ~0 rows (approximately)
/*!40000 ALTER TABLE `watch` DISABLE KEYS */;
INSERT INTO `watch` (`ckey`, `reason`, `timestamp`, `adminckey`, `last_editor`, `edits`) VALUES
	('AffectedArc07', 'Cant behave', '2020-04-24 18:06:33', 'AffectedArc07', NULL, NULL);
/*!40000 ALTER TABLE `watch` ENABLE KEYS */;

-- Dumping structure for table feedback.whitelist
DROP TABLE IF EXISTS `whitelist`;
CREATE TABLE IF NOT EXISTS `whitelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` text NOT NULL,
  `job` text DEFAULT NULL,
  `species` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- Dumping data for table feedback.whitelist: 0 rows
/*!40000 ALTER TABLE `whitelist` DISABLE KEYS */;
INSERT INTO `whitelist` (`id`, `ckey`, `job`, `species`) VALUES
	(1, 'AffectedArc07', 'Captain', 'Machine');
/*!40000 ALTER TABLE `whitelist` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));