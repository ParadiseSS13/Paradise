# Updating SQL from 73 to 74 -Tojo
# Adds Bloopers variables. Uses decimals, not sure if thats a problem.

ALTER TABLE `characters`
	ADD COLUMN `blooper_id` VARCHAR(45) NULL DEFAULT NULL AFTER `height`,
	ADD COLUMN `blooper_speed` DECIMAL(4,2) NULL DEFAULT NULL AFTER `blooper_id`,
	ADD COLUMN `blooper_pitch` DECIMAL(4,3) NULL DEFAULT NULL AFTER `blooper_speed`,
	ADD COLUMN `blooper_pitch_range` DECIMAL(4,3) NULL DEFAULT NULL AFTER `blooper_pitch`;
