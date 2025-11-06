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
	slot = ITEM_SLOT_EYES
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

/datum/gear/glasses/sechud
	display_name = "Classic security HUD"
	path = /obj/item/clothing/glasses/hud/security
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Detective", "Internal Affairs Agent","Magistrate")

/datum/gear/glasses/goggles
	display_name = "Goggles"
	path = /obj/item/clothing/glasses/goggles

/datum/gear/glasses/goggles_job
	main_typepath = /datum/gear/glasses/goggles_job
	subtype_selection_cost = FALSE

/datum/gear/glasses/goggles_job/sechudgoggles
	display_name = "Security HUD goggles"
	path = /obj/item/clothing/glasses/hud/security/goggles
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Detective", "Internal Affairs Agent", "Magistrate")

/datum/gear/glasses/goggles_job/medhudgoggles
	display_name = "Health HUD goggles"
	path = /obj/item/clothing/glasses/hud/health/goggles
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Coroner", "Chemist", "Virologist", "Psychiatrist", "Paramedic")

/datum/gear/glasses/goggles_job/diaghudgoggles
	display_name = "Diagnostic HUD goggles"
	path = /obj/item/clothing/glasses/hud/diagnostic/goggles
	allowed_roles = list("Research Director", "Scientist", "Roboticist")

/datum/gear/glasses/goggles_job/hydrohudgoggles
	display_name = "Hydroponic HUD goggles"
	path = /obj/item/clothing/glasses/hud/hydroponic/goggles
	allowed_roles = list("Botanist")

/datum/gear/glasses/goggles_job/skillhudgoggles
	display_name = "Skill HUD goggles"
	path = /obj/item/clothing/glasses/hud/skills/goggles
	allowed_roles = list("Psychiatrist", "Nanotrasen Representative", "Head of Personnel", "Captain")
