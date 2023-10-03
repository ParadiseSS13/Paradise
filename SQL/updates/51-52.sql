# Updating SQL from 51 to 52 -AffectedArc07
# Adding all department columns to playtime_history
ALTER TABLE `playtime_history`
	ADD COLUMN `time_crew` SMALLINT NOT NULL AFTER `time_living`,
	ADD COLUMN `time_special` SMALLINT NOT NULL AFTER `time_crew`,
	ADD COLUMN `time_command` SMALLINT NOT NULL AFTER `time_ghost`,
	ADD COLUMN `time_engineering` SMALLINT NOT NULL AFTER `time_command`,
	ADD COLUMN `time_medical` SMALLINT NOT NULL AFTER `time_engineering`,
	ADD COLUMN `time_science` SMALLINT NOT NULL AFTER `time_medical`,
	ADD COLUMN `time_supply` SMALLINT NOT NULL AFTER `time_science`,
	ADD COLUMN `time_security` SMALLINT NOT NULL AFTER `time_supply`,
	ADD COLUMN `time_silicon` SMALLINT NOT NULL AFTER `time_security`,
	ADD COLUMN `time_service` SMALLINT NOT NULL AFTER `time_silicon`;
