# Updating DB from 20-21
# Add new column uplink_pref (longtext) to table characters

# Add column to characters
ALTER TABLE `characters` ADD COLUMN `uplink_pref` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `autohiss`;
