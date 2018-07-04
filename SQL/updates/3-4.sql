#Updating the SQL from version 3 to version 4. -Kyep
#Adding new column to contain the atklog value.
ALTER TABLE `player`
	ADD `atklog` smallint(4) DEFAULT '0' AFTER `clientfps`;