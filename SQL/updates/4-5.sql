-- 20 May 2017, by Jordie0608

-- Created table `round` to replace tracking of the datapoints 'round_start', 'round_end', 'server_ip', 'game_mode', 'round_end_results', 'end_error', 'end_proper', 'emergency_shuttle', 'map_name' and 'station_renames' in the `feedback` table.
-- Once created, you must run 4-5.py to populate this table. Run python 4-5.py --help for usage.

CREATE TABLE `paradise`.`round` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `initialize_datetime` DATETIME NOT NULL,
  `start_datetime` DATETIME NULL,
  `end_datetime` DATETIME NULL,
  `server_ip` INT(10) UNSIGNED NOT NULL,
  `server_port` SMALLINT(5) UNSIGNED NOT NULL,
  `commit_hash` CHAR(40) NULL,
  `game_mode` VARCHAR(32) NULL,
  `game_mode_result` VARCHAR(64) NULL,
  `end_state` VARCHAR(64) NULL,
  `shuttle_name` VARCHAR(64) NULL,
  `map_name` VARCHAR(32) NULL,
  `station_name` VARCHAR(80) NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- It's not necessary to delete the rows from the `feedback` table but henceforth these datapoints will be in the `round` table.
-- Remember to add a prefix to the table names if you use them
