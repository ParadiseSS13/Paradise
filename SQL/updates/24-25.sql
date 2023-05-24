# Updates the DB from 24 to 25 -SabreML
# Increases the maximum length of `real_name` from 45 to 55 in the `characters` table.

ALTER TABLE `characters` MODIFY COLUMN `real_name` varchar(55) COLLATE utf8mb4_unicode_ci NOT NULL
