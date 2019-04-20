#Updating the SQL from version 5 to version 6. -Mark
#Adding new column to contain the atklog value.
ALTER TABLE `player`
	ADD `ambientocclusion` smallint(4) DEFAULT '1' AFTER `atklog`;