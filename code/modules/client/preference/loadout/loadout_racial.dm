/datum/gear/racial
	sort_category = "Racial"
	subtype_path = /datum/gear/racial
	cost = 1

/datum/gear/racial/taj
	display_name = "embroidered veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind
	slot = slot_glasses

/datum/gear/racial/taj/sec
	display_name = "sleek veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built security HUD."
	path = /obj/item/clothing/glasses/hud/security/tajblind
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Security Pod Pilot", "Internal Affairs Agent", "Magistrate")
	cost = 2

/datum/gear/racial/taj/med
	display_name = "lightweight veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built medical HUD."
	path = /obj/item/clothing/glasses/hud/health/tajblind
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Brig Physician" , "Coroner")
	cost = 2

/datum/gear/racial/taj/sci
	display_name = "hi-tech veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind/sci
	cost = 2

/datum/gear/racial/taj/eng
	display_name = "industrial veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind/eng
	cost = 2
	
/datum/gear/racial/taj/cargo
	display_name = "khaki veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. It is light and comfy!"
	path = /obj/item/clothing/glasses/tajblind/cargo
	cost = 2
	
/datum/gear/racial/footwraps
	display_name = "cloth footwraps"
	path = /obj/item/clothing/shoes/footwraps
	slot = slot_shoes
