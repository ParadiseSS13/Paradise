# Updating SQL from 70 to 71 -MigratingCocofruit
# Adding new table for bug reports
CREATE TABLE `bug_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author_ckey` varchar(32) NOT NULL,
  `title` MEDIUMTEXT COLLATE 'utf8mb4_general_ci',
  `expected_behavior` MEDIUMTEXT COLLATE 'utf8mb4_general_ci',
  `description` MEDIUMTEXT COLLATE 'utf8mb4_general_ci',
  `consequences` MEDIUMTEXT COLLATE 'utf8mb4_general_ci',
  `steps` MEDIUMTEXT COLLATE 'utf8mb4_general_ci',
  `logs` MEDIUMTEXT COLLATE 'utf8mb4_general_ci',
  `round_id` int(11),
  `server_byond_build` varchar(32),
  `client_byond_build` varchar(32),
  `server_commit` varchar(32) NOT NULL,
  `test_merges` MEDIUMTEXT COLLATE 'utf8mb4_general_ci',
  PRIMARY KEY (`id`) USING BTREE

) COLLATE = 'utf8mb4_general_ci' ENGINE = INNODB;
