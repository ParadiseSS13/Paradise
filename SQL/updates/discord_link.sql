#Updating the SQL for Discord account linking
#Adding new columns to contain the Discord account ID and Name values.
ALTER TABLE `player` ADD `discord_id` varchar(32) DEFAULT NULL AFTER `byond_date`;
ALTER TABLE `player` ADD `discord_name` varchar(32) DEFAULT NULL AFTER `discord_id`;
