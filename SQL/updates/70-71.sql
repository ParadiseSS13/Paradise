# Updating SQL from 70 to 71 -MigratingCocofruit
# Adding new table for bug reports
CREATE TABLE `bug_reports` (
  `db_uid` INT(32) NOT NULL,
  `author_ckey` varchar(32) NOT NULL,
  `title` MEDIUMTEXT COLLATE 'utf8mb4_general_ci',
  `round_id` int(11),
  `contents_json` LONGTEXT,
  CONSTRAINT bug_key PRIMARY KEY (`db_uid`,`author_ckey`) USING BTREE

) COLLATE = 'utf8mb4_general_ci' ENGINE = INNODB;
