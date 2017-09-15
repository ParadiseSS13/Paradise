#Updating the SQL from version 0 to version 1. -KasparoVv
#Adding new columns to contain the hex values (will be converted from RGB).
ALTER TABLE `characters`
	ADD `hair_colour` varchar(7) NOT NULL DEFAULT '#000000' AFTER `language`,
	ADD `secondary_hair_colour` varchar(7) NOT NULL DEFAULT '#000000' AFTER `hair_blue`,
	ADD `facial_hair_colour` varchar(7) NOT NULL DEFAULT '#000000' AFTER `secondary_hair_blue`,
	ADD `secondary_facial_hair_colour` varchar(7) NOT NULL DEFAULT '#000000' AFTER `facial_blue`,
	ADD `skin_colour` varchar(7) NOT NULL DEFAULT '#000000' AFTER `skin_tone`,
	ADD `head_accessory_colour` varchar(7) NOT NULL DEFAULT '#000000' AFTER `marking_colours`,
	ADD `eye_colour` varchar(7) NOT NULL DEFAULT '#000000' AFTER `alt_head_name`;

#Converting RGB colours to HEX colours and transferring them to the new columns.
UPDATE `characters`
	SET `hair_colour` = CONCAT("#", LPAD(HEX(`hair_red`), 2,'0'), LPAD(HEX(`hair_green`), 2,'0'), LPAD(HEX(`hair_blue`), 2,'0')),
	`secondary_hair_colour` = CONCAT("#", LPAD(HEX(`secondary_hair_red`), 2,'0'), LPAD(HEX(`secondary_hair_green`), 2,'0'), LPAD(HEX(`secondary_hair_blue`), 2,'0')),
	`facial_hair_colour` = CONCAT("#", LPAD(HEX(`facial_red`), 2,'0'), LPAD(HEX(`facial_green`), 2,'0'), LPAD(HEX(`facial_blue`), 2,'0')),
	`secondary_facial_hair_colour` = CONCAT("#", LPAD(HEX(`secondary_facial_red`), 2,'0'), LPAD(HEX(`secondary_facial_green`), 2,'0'), LPAD(HEX(`secondary_facial_blue`), 2,'0')),
	`skin_colour` = CONCAT("#", LPAD(HEX(`skin_red`), 2,'0'), LPAD(HEX(`skin_green`), 2,'0'), LPAD(HEX(`skin_blue`), 2,'0')),
	`head_accessory_colour` = CONCAT("#", LPAD(HEX(`head_accessory_red`), 2,'0'), LPAD(HEX(`head_accessory_green`), 2,'0'), LPAD(HEX(`head_accessory_blue`), 2,'0')),
	`eye_colour` = CONCAT("#", LPAD(HEX(`eyes_red`), 2,'0'), LPAD(HEX(`eyes_green`), 2,'0'), LPAD(HEX(`eyes_blue`), 2,'0'));

#Dropping the old columns now that the hex colour columns are in place.
ALTER TABLE `characters`
	DROP `hair_red`, DROP `hair_green`, DROP `hair_blue`,
	DROP `secondary_hair_red`, DROP `secondary_hair_green`, DROP `secondary_hair_blue`,
	DROP `facial_red`, DROP `facial_green`, DROP `facial_blue`,
	DROP `secondary_facial_red`, DROP `secondary_facial_green`, DROP `secondary_facial_blue`,
	DROP `skin_red`, DROP `skin_green`, DROP `skin_blue`,
	DROP `head_accessory_red`, DROP `head_accessory_green`, DROP `head_accessory_blue`,
	DROP `eyes_red`, DROP `eyes_green`, DROP `eyes_blue`;
