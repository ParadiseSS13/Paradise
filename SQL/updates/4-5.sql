-- 20 May 2017, by Jordie0608

-- Created table `round` to replace tracking of the datapoints 'round_start', 'round_end', 'server_ip', 'game_mode', 'round_end_results', 'end_error', 'end_proper', 'emergency_shuttle', 'map_name' and 'station_renames' in the `feedback` table.
-- Once created this table is populated with rows from the `feedback` table.

START TRANSACTION;
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
INSERT INTO `paradise`.`round`
(`id`, `start_datetime`, `end_datetime`, `server_ip`, `server_port`, `commit_hash`, `game_mode`, `game_mode_result`, `end_state`, `shuttle_name`,
	`map_name`, `station_name`)
SELECT DISTINCT ri.round_id, IFNULL(STR_TO_DATE(st.details,'%a %b %e %H:%i:%s %Y'), TIMESTAMP(0)), STR_TO_DATE(et.details,'%a %b %e %H:%i:%s %Y'), IFNULL(INET_ATON(SUBSTRING_INDEX(IF(si.details = '', '0', IF(SUBSTRING_INDEX(si.details, ':', 1) LIKE '%_._%', si.details, '0')), ':', 1)), INET_ATON(0)), IFNULL(IF(si.details LIKE '%:_%', CAST(SUBSTRING_INDEX(si.details, ':', -1) AS UNSIGNED), '0'), '0'), ch.details, gm.details, mr.details, IFNULL(es.details, ep.details), ss.details, mn.details, sn.details
FROM `paradise`.`feedback`AS ri
LEFT JOIN `paradise`.`feedback` AS st ON ri.round_id = st.round_id AND st.var_name = "round_start" LEFT JOIN `paradise`.`feedback` AS et ON ri.round_id = et.round_id AND et.var_name = "round_end" LEFT JOIN `paradise`.`feedback` AS si ON ri.round_id = si.round_id AND si.var_name = "server_ip" LEFT JOIN `paradise`.`feedback` AS ch ON ri.round_id = ch.round_id AND ch.var_name = "revision" LEFT JOIN `paradise`.`feedback` AS gm ON ri.round_id = gm.round_id AND gm.var_name = "game_mode" LEFT JOIN `paradise`.`feedback` AS mr ON ri.round_id = mr.round_id AND mr.var_name = "round_end_result" LEFT JOIN `paradise`.`feedback` AS es ON ri.round_id = es.round_id AND es.var_name = "end_state" LEFT JOIN `paradise`.`feedback` AS ep ON ri.round_id = ep.round_id AND ep.var_name = "end_proper" LEFT JOIN `paradise`.`feedback` AS ss ON ri.round_id = ss.round_id AND ss.var_name = "emergency_shuttle" LEFT JOIN `paradise`.`feedback` AS mn ON ri.round_id = mn.round_id AND mn.var_name = "map_name" LEFT JOIN `paradise`.`feedback` AS sn ON ri.round_id = sn.round_id AND sn.var_name = "station_renames";
COMMIT;

-- It's not necessary to delete the rows from the `feedback` table but henceforth these datapoints will be in the `round` table.

-- Remember to add a prefix to the table names if you use them
