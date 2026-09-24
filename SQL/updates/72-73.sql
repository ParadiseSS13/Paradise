# Updating SQL from 72 to 73 -AffectedArc07
# Replaces the old forum links table with a generic tasks table for TaskDaemon to pick up
DROP TABLE `oauth_tokens`;

CREATE TABLE `task_queue` (
	`task_id` UUID NOT NULL,
	`task_type` VARCHAR(128) NOT NULL COLLATE 'utf8mb4_general_ci',
	`task_arguments` VARCHAR(128) NOT NULL COLLATE 'utf8mb4_general_ci',
	`date_inserted` DATETIME NOT NULL,
	`date_processed` DATETIME NULL DEFAULT NULL,
	`processed` TINYINT(1) NOT NULL DEFAULT '0',
	PRIMARY KEY (`task_id`) USING BTREE,
	INDEX `processed` (`processed`) USING BTREE
) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;
