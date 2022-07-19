#Updating the SQL from version 11 to version 12. -AffectedArc07
#Creating a table for the new changelog system

DROP TABLE IF EXISTS `changelog`;
CREATE TABLE IF NOT EXISTS `changelog` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`pr_number` INT(11) NOT NULL,
	`date_merged` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
	`author` VARCHAR(32) NOT NULL,
	`cl_type` ENUM('FIX','WIP','TWEAK','SOUNDADD','SOUNDDEL','CODEADD','CODEDEL','IMAGEADD','IMAGEDEL','SPELLCHECK','EXPERIMENT') NOT NULL,
	`cl_entry` TEXT NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
