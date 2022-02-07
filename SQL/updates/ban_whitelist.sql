--
-- Table structure for table `ban_whitelist`
--
DROP TABLE IF EXISTS `ban_whitelist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ban_whitelist`
(
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `ckey` VARCHAR(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ckey` (`ckey`),
  KEY `computerid` (`computerid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;
