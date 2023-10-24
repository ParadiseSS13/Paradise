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


/datum/gear/racial
	sort_category = "Racial"
	main_typepath = /datum/gear/racial
	cost = 1

/datum/gear/racial/taj
	display_name = "Embroidered veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind
	slot = SLOT_HUD_GLASSES

/datum/gear/racial/taj/sec
	display_name = "Sleek veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built security HUD."
	path = /obj/item/clothing/glasses/hud/security/tajblind
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Internal Affairs Agent", "Magistrate", "Detective")
	cost = 2

/datum/gear/racial/taj/med
	display_name = "Lightweight veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built medical HUD."
	path = /obj/item/clothing/glasses/hud/health/tajblind
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Coroner")
	cost = 2

/datum/gear/racial/taj/sci
	display_name = "Hi-tech veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind/sci
	cost = 2

/datum/gear/racial/taj/eng
	display_name = "Industrial veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind/eng
	cost = 2

/datum/gear/racial/taj/cargo
	display_name = "Khaki veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. It is light and comfy!"
	path = /obj/item/clothing/glasses/tajblind/cargo
	cost = 2

/datum/gear/racial/footwraps
	display_name = "Cloth footwraps"
	path = /obj/item/clothing/shoes/footwraps
	slot = SLOT_HUD_SHOES
