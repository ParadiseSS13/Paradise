# Updating SQL from 47 to 48 -AffectedArc07
# Updates ban table to add an exportable flag column
ALTER TABLE `ban`
	ADD COLUMN `exportable` TINYINT NOT NULL DEFAULT '1' AFTER `unbanned_ip`;

ALTER TABLE `ban`
	ADD INDEX `exportable` (`exportable`);

# Marks all existing bans as non-exportable
UPDATE ban SET exportable=0
