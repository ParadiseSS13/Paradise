# Updating SQL from 51 to 52 -Octus
# Add characther descriptors of height and build to preference menu

ALTER TABLE `characters` CHANGE COLUMN `physique` `physique` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT `of average build`;
ALTER TABLE `characters` CHANGE COLUMN `height` `height` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT `of average height`;
