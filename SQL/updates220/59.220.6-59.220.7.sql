# Updating DB from 59.220.6 to 59.220.7
# Adds SS220 toggle prefs ~Maxiemar

DROP TABLE IF EXISTS `player_220`;
CREATE TABLE `player_220` (
	`ckey` VARCHAR(32) NOT NULL COLLATE utf8mb4_unicode_ci,
	`toggles` int(11) DEFAULT NULL,
	PRIMARY KEY (`ckey`) USING BTREE
) COLLATE = utf8mb4_unicode_ci ENGINE = InnoDB;

ALTER TABLE `player_220`
ADD CONSTRAINT `fk_player_220_ckey`
FOREIGN KEY (`ckey`) REFERENCES `player`(`ckey`)
ON DELETE CASCADE
ON UPDATE CASCADE;

DROP TRIGGER IF EXISTS `player_insert`;
DELIMITER //
CREATE TRIGGER `player_insert`
AFTER INSERT ON `player`
FOR EACH ROW
BEGIN
    INSERT INTO `player_220` (`ckey`)
    VALUES (NEW.ckey);
END;
//
DELIMITER ;

INSERT INTO `player_220` (`ckey`)
SELECT `ckey`
FROM `player`;
