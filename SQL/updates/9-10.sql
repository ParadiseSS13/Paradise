# Change afk_watch to AFK_WATCH_warn_minutes and AFK_WATCH_cryo_minutes which gives users the option to make use of the AFK watcher subsystem
ALTER TABLE `player` ADD `AFK_WATCH_warn_minutes` tinyint(1) NOT NULL DEFAULT '0' AFTER `afk_watch`;
UPDATE `player` SET `AFK_WATCH_warn_minutes` = 5 WHERE `afk_watch` = 1;
ALTER TABLE `player` ADD `AFK_WATCH_cryo_minutes` tinyint(1) NOT NULL DEFAULT '0' AFTER `AFK_WATCH_warn_minutes`;
UPDATE `player` SET `AFK_WATCH_cryo_minutes` = 2 WHERE `afk_watch` = 1;
ALTER TABLE `player` DROP COLUMN `afk_watch`;