# Add afk_watch which gives users the option to make use of the AFK watcher subsystem
ALTER TABLE `player` ADD `afk_watch` tinyint(1) NOT NULL DEFAULT '0';
