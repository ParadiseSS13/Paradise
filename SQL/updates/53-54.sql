#Updating SQL from 53 to 54 -Wilk
#Add a choice for what type of brain borgs want to have

ALTER TABLE `characters`
	ADD COLUMN `cyborg_brain_type` ENUM('MMI', 'Robobrain', 'Positronic') NOT NULL DEFAULT 'MMI' AFTER `height`;
