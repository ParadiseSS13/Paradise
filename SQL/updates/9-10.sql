#add column to force person to enter a code word before being allowed to enter the game
ALTER TABLE `ban` 
	ADD `challenge` BOOLEAN NOT NULL DEFAULT FALSE AFTER `unbanned_ip`;