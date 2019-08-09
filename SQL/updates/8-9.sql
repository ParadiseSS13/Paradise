# Add secret column to notes to allow for admins to hide and show admin remarks to players
ALTER TABLE `notes` ADD COLUMN `secret` TINYINT(1) NOT NULL DEFAULT '1'  AFTER `server`