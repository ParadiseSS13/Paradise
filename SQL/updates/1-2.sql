#Updating the SQL from version 1 to version 2. -uraniummeltdown
#Adding new column to contain the clientfps value.
ALTER TABLE `player`
	ADD `clientfps` smallint(4) DEFAULT '0' AFTER `exp`;