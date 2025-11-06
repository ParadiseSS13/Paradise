# Updating DB from 57-58 ~Burza
# Changes the data type for the `ip` column in `connection_log` from VARCHAR to INT

# Creates a temporary column for our new data type
ALTER TABLE `connection_log`
ADD COLUMN `ip_int` INT UNSIGNED NULL;

# Copies the data from the `ip` column to `ip_int` as our new data type
UPDATE `connection_log`
SET `ip_int` = INET_ATON(`ip`);

# Deletes the old `ip` column from the table
ALTER TABLE `connection_log` DROP COLUMN `ip`;

# Updates the name of the temporary column to take place of the original
ALTER TABLE `connection_log`
CHANGE COLUMN `ip_int` `ip` INT UNSIGNED NOT NULL AFTER `ckey`;
