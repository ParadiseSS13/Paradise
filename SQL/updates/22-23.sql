# Updating SQL from version 22 to 23 -AffectedArc07
# Converts existing MyISAM tables to InnoDB

ALTER TABLE `customuseritems` ENGINE=InnoDB;
ALTER TABLE `death` ENGINE=InnoDB;
ALTER TABLE `feedback` ENGINE=InnoDB;
ALTER TABLE `karma` ENGINE=InnoDB;
ALTER TABLE `karmatotals` ENGINE=InnoDB;
ALTER TABLE `legacy_population` ENGINE=InnoDB;
ALTER TABLE `library` ENGINE=InnoDB;
ALTER TABLE `whitelist` ENGINE=InnoDB;
