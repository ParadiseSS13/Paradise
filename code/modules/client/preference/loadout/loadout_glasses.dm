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


/datum/gear/glasses
	main_typepath = /datum/gear/glasses
	slot = slot_glasses
	sort_category = "Glasses"

/datum/gear/glasses/sunglasses
	display_name = "Cheap sunglasses"
	path = /obj/item/clothing/glasses/sunglasses_fake

/datum/gear/glasses/eyepatch
	display_name = "Eyepatch"
	path = /obj/item/clothing/glasses/eyepatch

/datum/gear/glasses/hipster
	display_name = "Hipster glasses"
	path = /obj/item/clothing/glasses/regular/hipster

/datum/gear/glasses/monocle
	display_name = "Monocle"
	path = /obj/item/clothing/glasses/monocle

/datum/gear/glasses/prescription
	display_name = "Prescription glasses"
	path = /obj/item/clothing/glasses/regular
