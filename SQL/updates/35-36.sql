# Updates DB from 35 to 36 -AffectedArc07
# Removes karma job prefs

ALTER TABLE `characters`
	DROP COLUMN `job_karma_high`,
	DROP COLUMN `job_karma_med`,
	DROP COLUMN `job_karma_low`;
