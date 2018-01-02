/datum/gear/racial
	sort_category = "Racial"
	subtype_path = /datum/gear/racial
	cost = 2


/datum/gear/racial/tajciv
	display_name = "embroidered veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind

/datum/gear/racial/tajsec
	display_name = "sleek veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built security HUD."
	path = /obj/item/clothing/glasses/hud/security/tajblind
	allowed_roles = list("Head of Security", "Warden", "Security Officer", "Security Pod Pilot", "Internal Affairs Agent", "Magistrate")

/datum/gear/racial/tajmed
	display_name = "lightweight veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built medical HUD."
	path = /obj/item/clothing/glasses/hud/health/tajblind
	allowed_roles = list("Chief Medical Officer", "Medical Doctor", "Chemist", "Psychiatrist", "Paramedic", "Virologist", "Brig Physician" , "Coroner")

/datum/gear/racial/tajsci
	display_name = "hi-tech veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind/sci
	allowed_roles = list("Scientist", "Research Director", "Robotocist")

/datum/gear/racial/tajeng
	display_name = "industrial veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind/eng
	allowed_roles = list("Chief Engineer", "Station Engineer", "Mechanic", "Life Support Specialist")

/datum/gear/racial/tajcargo
	display_name = "khaki veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. It is light and comfy!"
	path = /obj/item/clothing/glasses/tajblind/cargo
	allowed_roles = list("Quartermaster","Cargo Technician", "Miner")