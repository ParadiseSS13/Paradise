--
-- Table structure for table `budget`
--
DROP TABLE IF EXISTS `budget`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `budget`
(
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`date` DATETIME DEFAULT now() NOT NULL,
	`ckey` VARCHAR(32) NOT NULL,
	`amount` INT(10) UNSIGNED NOT NULL,
	`source` VARCHAR(32) NOT NULL,
	`date_start` DATETIME DEFAULT now() NOT NULL,
	`date_end` DATETIME DEFAULT (now() + INTERVAL 1 MONTH),
	`is_valid` BOOLEAN DEFAULT true NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;
