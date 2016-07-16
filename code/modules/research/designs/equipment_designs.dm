/////////////////////////////////////////
/////////////////Equipment///////////////
/////////////////////////////////////////
/datum/design/exwelder
	name = "Experimental Welding Tool"
	desc = "An experimental welder capable of self-fuel generation."
	id = "exwelder"
	req_tech = list("materials" = 4, "engineering" = 4, "bluespace" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_PLASMA = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/weapon/weldingtool/experimental
	category = list("Equipment")

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list("Equipment")

/datum/design/health_hud_night
	name = "Night Vision Health Scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	id = "health_hud_night"
	req_tech = list("biotech" = 4, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_URANIUM = 1000, MAT_SILVER = 250)
	build_path = /obj/item/clothing/glasses/hud/health/night
	category = list("Equipment")

/datum/design/magboots
	name = "Magnetic Boots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	id = "magboots"
	req_tech = list("materials" = 4, "magnets" = 4, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list("Equipment")

/datum/design/night_vision_goggles
	name = "Night Vision Goggles"
	desc = "Goggles that let you see through darkness unhindered."
	id = "night_vision_goggles"
	req_tech = list("magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/night
	category = list("Equipment")

/datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/security
	category = list("Equipment")

/datum/design/security_hud_night
	name = "Night Vision Security HUD"
	desc = "A heads-up display which provides id data and vision in complete darkness."
	id = "security_hud_night"
	req_tech = list("magnets" = 5, "combat" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_URANIUM = 1000, MAT_GOLD = 350)
	build_path = /obj/item/clothing/glasses/hud/security/night
	category = list("Equipment")

/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used for seeing walls, floors, and stuff through anything."
	id = "mesons"
	req_tech = list("materials" = 3, "magnets" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 300, MAT_PLASMA = 100)
	build_path = /obj/item/clothing/glasses/meson
	category = list("Equipment")

/datum/design/nvgmesons
	name = "Night Vision Optical Meson Scanners"
	desc = "Prototype meson scanners fitted with an extra sensor which amplifies the visible light spectrum and overlays it to the UHD display."
	id = "nvgmesons"
	req_tech = list("materials" = 5, "magnets" = 5, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 400, MAT_PLASMA = 250, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/meson/night
	category = list("Equipment")

/datum/design/air_horn
	name = "Air Horn"
	desc = "Damn son, where'd you find this?"
	id = "air_horn"
	req_tech = list("materials" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_BANANIUM = 1000)
	build_path = /obj/item/weapon/bikehorn/airhorn
	category = list("Equipment")

/datum/design/welding_mask
	name = "Welding Gas Mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	id = "weldingmask"
	req_tech = list("materials" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/clothing/mask/gas/welding
	category = list("Equipment")

/datum/design/portaseeder
	name = "Portable Seed Extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	build_type = PROTOLATHE
	req_tech = list("biotech" = 2, "materials" = 2)
	materials = list(MAT_METAL = 200, MAT_GLASS = 100)
	build_path = /obj/item/weapon/storage/bag/plants/portaseeder
	category = list("Equipment")

/datum/design/detective_scanner
	name = "Forensic Scanner"
	desc = "A high tech scanner designed for forensic evidence collection, DNA recovery, and fiber analysis."
	id = "detectivescanner"
	req_tech = list("biotech" = 2, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000)
	build_path = /obj/item/device/detective_scanner
	locked = 1      //no validhunting scientists.
	category = list("Equipment")

/datum/design/sci_goggles
	name = "Science Goggles"
	desc = "Goggles fitted with a portable analyzer capable of determining the research worth of an item or components of a machine."
	id = "scigoggles"
	req_tech = list("materials" = 3, "magnets" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 300)
	build_path = /obj/item/clothing/glasses/science
	category = list("Equipment")

/datum/design/nv_sci_goggles
	name = "Night Vision Science Goggles"
	desc = "Like Science google, but works in darkness."
	id = "nvscigoggles"
	req_tech = list("materials" = 5, "magnets" = 5, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 300, MAT_PLASMA = 250, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/science/night
	category = list("Equipment")

/datum/design/diagnostic_hud
	name = "Diagnostic HUD"
	desc = "A HUD used to analyze and determine faults within robotic machinery."
	id = "dianostic_hud"
	req_tech = list("magnets" = 3, "engineering" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/clothing/glasses/hud/diagnostic
	category = list("Equipment")

/datum/design/diagnostic_hud_night
	name = "Night Vision Diagnostic HUD"
	desc = "Upgraded version of the diagnostic HUD designed to function during a power failure."
	id = "dianostic_hud_night"
	req_tech = list("magnets" = 5, "engineering" = 4, "materials" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 200, "$glass" = 200, "$uranium" = 1000, "$plasma" = 300)
	build_path = /obj/item/clothing/glasses/hud/diagnostic/night
	category = list("Equipment")

/datum/design/hydroponic_hud
	name = "Hydroponic HUD"
	desc = "A HUD used to analyze the health and status of plants growing in hydro trays and soil."
	id = "hydroponic_hud"
	req_tech = list("magnets" = 3, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/clothing/glasses/hud/hydroponic
	category = list("Equipment")

/datum/design/hydroponic_hud_night
	name = "Night Vision Hydroponic HUD"
	desc = "A HUD used to analyze the health and status of plants growing in low-light environments."
	id = "hydroponic_hud_night"
	req_tech = list("magnets" = 5, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 200, "$glass" = 200, "$uranium" = 1000, "$plasma" = 200)
	build_path = /obj/item/clothing/glasses/hud/hydroponic/night
	category = list("Equipment")