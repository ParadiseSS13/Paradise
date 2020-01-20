/datum/gear/racial
	sort_category = "Racial"
	subtype_path = /datum/gear/racial

/datum/gear/racial/taj
	slot = slot_glasses
	cost = 2

/datum/gear/racial/taj/civ
	display_name = "embroidered veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind
	cost = 1

/datum/gear/racial/taj/sec
	display_name = "sleek veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built security HUD."
	path = /obj/item/clothing/glasses/hud/security/tajblind
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Security Pod Pilot", "Internal Affairs Agent", "Magistrate")

/datum/gear/racial/taj/med
	display_name = "lightweight veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built medical HUD."
	path = /obj/item/clothing/glasses/hud/health/tajblind
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Brig Physician" , "Coroner")

/datum/gear/racial/taj/sci
	display_name = "hi-tech veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind/sci

/datum/gear/racial/taj/eng
	display_name = "industrial veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind/eng

/datum/gear/racial/taj/cargo
	display_name = "khaki veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. It is light and comfy!"
	path = /obj/item/clothing/glasses/tajblind/cargo

/datum/gear/racial/footwraps
	display_name = "cloth footwraps"
	path = /obj/item/clothing/shoes/footwraps
	slot = slot_shoes
	cost = 1
