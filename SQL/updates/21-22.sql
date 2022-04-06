# Updating DB from 21-22, -AffectedArc07
# Changes `rank` to `admin_rank` to remove use of reserved keyword

ALTER TABLE `admin` CHANGE COLUMN `rank` `admin_rank` VARCHAR(32) NOT NULL DEFAULT 'Administrator' COLLATE 'utf8mb4_unicode_ci' AFTER `ckey`;
