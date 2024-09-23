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


/datum/gear/gloves
	main_typepath = /datum/gear/gloves
	slot = SLOT_HUD_GLOVES
	sort_category = "Gloves"

/datum/gear/gloves/fingerless
	display_name = "Fingerless Gloves"
	path = /obj/item/clothing/gloves/fingerless

/datum/gear/gloves/silverring
	display_name = "Silver ring"
	path = /obj/item/clothing/gloves/ring/silver

/datum/gear/gloves/goldring
	display_name = "Gold ring"
	path = /obj/item/clothing/gloves/ring/gold
