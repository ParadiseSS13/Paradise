#Updating the SQL from version 5 to version 6. -AffectedArc07
#Creating a table to track tickets
DROP TABLE IF EXISTS `tickets`;
CREATE TABLE IF NOT EXISTS `tickets` (
  `db_ticket_id` int(11) NOT NULL AUTO_INCREMENT,
  `roundstart_time` datetime NOT NULL DEFAULT current_timestamp(),
  `round_ticket_id` int(11) NOT NULL DEFAULT 0,
  `opening_ckey` varchar(64) NOT NULL DEFAULT '0',
  `closing_ckey` varchar(64) NOT NULL DEFAULT '0',
  `initial_message` varchar(64) NOT NULL DEFAULT '0',
  `opened_at` int(11) NOT NULL DEFAULT 0,
  `closed_at` int(11) NOT NULL DEFAULT 0,
  `open_duration` int(11) NOT NULL DEFAULT 0,
  `close_state` varchar(64) NOT NULL DEFAULT '0',
  PRIMARY KEY (`db_ticket_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
