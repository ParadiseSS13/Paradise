# Updating SQL from 71 to 72 -MigratingCocofruit
# Change the bug reports table
ALTER TABLE `bug_reports` ADD `id` INT NOT NULL AUTO_INCREMENT;
ALTER TABLE `bug_reports` CHANGE COLUMN 'uid' `filetime` DATETIME NOT NULL DEFAULT NOW();
ALTER TABLE `bug_reports` ADD `submitted` BIT(2) NOT NULL DEFAULT 0,
ALTER TABLE `bug_reports` PRIMARY KEY (`id`),
ALTER TABLE `bug_reports` INDEX `submitted` (`submitted`)
