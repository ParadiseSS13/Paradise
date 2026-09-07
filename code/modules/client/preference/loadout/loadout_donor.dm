/*
######################################################################################
##																					##
##								IMPORTANT README									##
##																					##
##	  Changing any /datum/gear typepaths --WILL-- break people's loadouts.			##
##	The typepaths are stored directly in the `characters.gear` column of the DB.	##
##		Please inform the server host if you wish to modify any of these.			##
##																					##
######################################################################################
*/


/datum/gear/donor
	donator_tier = 2
	sort_category = "Donor"
	main_typepath = /datum/gear/donor

/datum/gear/donor/furgloves
	display_name = "Fur Gloves"
	path = /obj/item/clothing/gloves/furgloves

/datum/gear/donor/furboots
	display_name = "Fur Boots"
	path = /obj/item/clothing/shoes/furboots

/datum/gear/donor/noble_boot
	display_name = "Noble Boots"
	path = /obj/item/clothing/shoes/fluff/noble_boot

/datum/gear/donor/furcape
	display_name = "Fur Cape"
	path = /obj/item/clothing/neck/cloak/furcape

/datum/gear/donor/furcoat
	display_name = "Fur Coat"
	path = /obj/item/clothing/suit/furcoat

/datum/gear/donor/kamina
	display_name = "Spiky Orange-tinted Shades"
	path = /obj/item/clothing/glasses/fluff/kamina

/datum/gear/donor/green
	display_name = "Spiky Green-tinted Shades"
	path = /obj/item/clothing/glasses/fluff/kamina/green

/datum/gear/donor/threedglasses
	display_name = "Threed Glasses"
	path = /obj/item/clothing/glasses/threedglasses

/datum/gear/donor/blacksombrero
	display_name = "Black Sombrero"
	path = /obj/item/clothing/head/fluff/blacksombrero

/datum/gear/donor/guardhelm
	display_name = "Plastic Guard helm"
	path = /obj/item/clothing/head/fluff/guardhelm

/datum/gear/donor/goldtophat
	display_name = "Gold-trimmed Top Hat"
	path = /obj/item/clothing/head/fluff/goldtophat

/datum/gear/donor/goldtophat/red
	display_name = "Red Gold-trimmed Top Hat"
	path = /obj/item/clothing/head/fluff/goldtophat/red

/datum/gear/donor/goldtophat/blue
	display_name = "Blue Gold-trimmed Top Hat"
	path = /obj/item/clothing/head/fluff/goldtophat/blue

/datum/gear/donor/mushhat
	display_name = "Mushroom Hat"
	path = /obj/item/clothing/head/fluff/mushhat

/datum/gear/donor/furcap
	display_name = "Fur Cap"
	path = /obj/item/clothing/head/furcap

/datum/gear/donor/welding_blueflame
	display_name = "Blue flame decal welding helmet"
	path = /obj/item/clothing/head/welding/flamedecal/blue
	allowed_roles = list("Chief Engineer", "Station Engineer", "Life Support Specialist", "Roboticist")
	cost = 2

/datum/gear/donor/welding_white
	display_name = "White decal welding helmet"
	path = /obj/item/clothing/head/welding/white
	allowed_roles = list("Chief Engineer", "Station Engineer", "Life Support Specialist", "Roboticist")
	cost = 2

/datum/gear/donor/fawkes
	display_name = "Guy Fawkes mask"
	path = /obj/item/clothing/mask/fawkes

/datum/gear/donor/id_decal_silver
	display_name = "Silver ID Decal"
	path = /obj/item/id_decal/silver
	donator_tier = 3
	cost = 2

/datum/gear/donor/id_decal_prisoner
	display_name = "Prisoner ID Decal"
	path = /obj/item/id_decal/prisoner
	donator_tier = 3
	cost = 2

/datum/gear/donor/id_decal_emag
	display_name = "Emag ID Decal"
	path = /obj/item/id_decal/emag
	donator_tier = 3
	cost = 2

/datum/gear/donor/id_decal_gold
	display_name = "Gold ID Decal"
	path = /obj/item/id_decal/gold
	donator_tier = 4
	cost = 4
