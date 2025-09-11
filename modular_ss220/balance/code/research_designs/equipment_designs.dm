/datum/design/nvg_med
	name = "Night Vision Health Scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	id = "nvg_med"
	req_tech = list("magnets" = 6, "plasmatech" = 6, "engineering" = 6, "biotech" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_SILVER = 1000)
	build_path = /obj/item/clothing/glasses/hud/health/night
	category = list("Equipment")

/datum/design/nvg_sec
	name = "Night Vision Security HUD"
	desc = "A heads-up display which provides id data and vision in complete darkness."
	id = "nvg_sec"
	req_tech = list("magnets" = 6, "plasmatech" = 6, "engineering" = 6, "combat" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_TITANIUM = 1000)
	build_path = /obj/item/clothing/glasses/hud/security/night
	category = list("Equipment")

/datum/design/nvg_jan
	name = "Night Vision Janitor HUD"
	desc = "A janitorial filth scanner fitted with a light amplifier."
	id = "nvg_jan"
	req_tech = list("magnets" = 6, "plasmatech" = 6, "engineering" = 6, "biotech" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_PLASMA = 1000)
	build_path = /obj/item/clothing/glasses/hud/janitor/night
	category = list("Equipment", "Janitorial")

/datum/design/nvg_sci
	name = "Night Vision Science Goggles"
	desc = "Like Science Goggles, but works in darkness."
	id = "nvg_sci"
	req_tech = list("magnets" = 6, "plasmatech" = 6, "engineering" = 6, "toxins" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_PLASMA = 1000)
	build_path = /obj/item/clothing/glasses/science/night
	category = list("Equipment")

/datum/design/nvg_diag
	name = "Night Vision Diagnostic HUD"
	desc = "Upgraded version of the diagnostic HUD designed to function during a power failure."
	id = "nvg_diag"
	req_tech = list("magnets" = 6, "plasmatech" = 6, "engineering" = 6, "powerstorage" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_PLASMA = 1000)
	build_path = /obj/item/clothing/glasses/hud/diagnostic/night
	category = list("Equipment")

/datum/design/nvg_hyd
	name = "Night Vision Hydroponic HUD"
	desc = "A HUD used to analyze the health and status of plants growing in low-light environments."
	id = "nvg_hyd"
	req_tech = list("magnets" = 6, "plasmatech" = 6, "engineering" = 6, "biotech" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_PLASMA = 1000)
	build_path = /obj/item/clothing/glasses/hud/hydroponic/night
	category = list("Equipment")
