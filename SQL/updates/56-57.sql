#Updating SQL from 56-57 -Daylight
#Allows players to set defaults for AI related variables

ALTER TABLE `characters`
	ADD COLUMN `ai_name` varchar(55) COLLATE utf8mb4_unicode_ci NOT NULL;
	ADD COLUMN `cyborg_name` varchar(55) COLLATE utf8mb4_unicode_ci NOT NULL;
	ADD COLUMN `core_display` varchar(55) COLLATE utf8mb4_unicode_ci NOT NULL;
	ADD COLUMN `hologram_category` varchar(55) COLLATE utf8mb4_unicode_ci NOT NULL;
	ADD COLUMN `hologram_name` varchar(55) COLLATE utf8mb4_unicode_ci NOT NULL;
