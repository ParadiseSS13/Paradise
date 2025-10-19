# Updating SQL from 70 to 71 -MigratingCocofruit
# Adding new table for bug reports
CREATE TABLE `bug_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author_ckey` varchar(32) NOT NULL,
  `title` MEDIUMTEXT COLLATE 'utf8mb4_general_ci',
  `round_id` int(11),
  `contents_json` LONGTEXT,
  PRIMARY KEY (`id`) USING BTREE

) COLLATE = 'utf8mb4_general_ci' ENGINE = INNODB;
