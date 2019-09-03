#Updating the SQL from version 8 to version 9. -affectedarc07
#Adding new column to contain the parallax value.
ALTER TABLE `player`
	ADD `parallax` tinyint(1) DEFAULT '8' AFTER `fupdate`;
