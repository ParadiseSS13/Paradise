# Updates DB from 26 to 27 -AffectedArc07
# Adds a new table for instance data caching, and server_id fields on other tables

CREATE TABLE `instance_data_cache` (
	`server_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`key_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`key_value` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`last_updated` TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	PRIMARY KEY (`server_id`, `key_name`) USING HASH
) COLLATE='utf8mb4_general_ci' ENGINE=MEMORY;

