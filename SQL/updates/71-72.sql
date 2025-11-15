# Updating SQL from 71 to 72 -MigratingCocofruit
# Change the bug reports table
CREATE TABLE `bug_reports` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `filetime` DATETIME NOT NULL DEFAULT NOW(),
    `author_ckey` VARCHAR(32) NOT NULL COLLATE 'utf8mb4_general_ci',
    `title` MEDIUMTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
    `round_id` INT(11) NULL DEFAULT NULL,
    `contents_json` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
    `submitted` BIT(2) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    INDEX `submitted` (`submitted`)
)
COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;
