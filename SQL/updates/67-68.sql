# Updating DB from 67-68 -AffectedArc07
# Changes the data types in ip2group from varchar to int

# Create temporary table
CREATE TABLE `ip2group_copy` (
	`ip` INT UNSIGNED NOT NULL,
	`date` TIMESTAMP NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	`groupstr` INT UNSIGNED NOT NULL,
	PRIMARY KEY (`ip`) USING BTREE,
	INDEX `groupstr` (`groupstr`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

# Migrate data
DELETE FROM ip2group WHERE groupstr = ''; # This is junk

INSERT INTO ip2group_copy (ip, date, groupstr)
SELECT INET_ATON(`ip`), `date`, CAST(`groupstr` AS UNSIGNED) FROM ip2group;

# Drop old table
DROP TABLE `ip2group`;

# Rename new table
RENAME TABLE `ip2group_copy` TO `ip2group`;
