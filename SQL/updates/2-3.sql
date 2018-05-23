#Updating the SQL from version 2 to version 3. - Birdtalon
#Adding new column to separate admin toggles from regular player ones as we had exceeded the 16-bit limit
ALTER TABLE `player` ADD `admintoggles` mediumint(8) DEFAULT '0' AFTER `toggles`;