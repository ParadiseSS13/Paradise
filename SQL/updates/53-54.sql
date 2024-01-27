#Updating SQL from 53 to 54 -Wilk
#Add a choice for what type of brain borgs want to have

ALTER TABLE 'characters'
	ADD COLUMN 'cyborg_brain_type' INT(1) NOT NULL DEFAULT '0' AFTER 'height'
