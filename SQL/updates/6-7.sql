#Updating the SQL from version 6 to version 7. -fethas
#Adding new columns to contain special character names.
ALTER TABLE `characters`
	ADD `clown_name` varchar(45) NOT NULL AFTER `autohiss`,
	ADD `mime_name` varchar(45) NOT NULL AFTER `clown_name`,
	ADD `ai_name` varchar(45) NOT NULL AFTER `mime_name`,
	ADD `cyborg_name` varchar(45) NOT NULL AFTER `ai_name`,
	ADD `diety_name` varchar(45) NOT NULL AFTER `cyborg_name`,
	ADD `religion_name` varchar(45) NOT NULL AFTER `diety_name`;