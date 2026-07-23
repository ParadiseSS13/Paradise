/////////////////////////////////////////
/////////////////Equipment///////////////
/////////////////////////////////////////
/datum/design/exwelder
	name = "Experimental Welding Tool"
	desc = "An experimental welder capable of self-fuel generation."
	id = "exwelder"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_PLASMA = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/weldingtool/experimental
	category = list("Equipment")

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list("Equipment")

/datum/design/magboots
	name = "Magnetic Boots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	id = "magboots"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list("Equipment")

/datum/design/night_vision_goggles
	name = "Night Vision Goggles"
	desc = "Goggles that let you see through darkness unhindered."
	id = "night_vision_goggles"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_PLASMA = 350, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/night
	category = list("Equipment")

/datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/security
	category = list("Equipment")

/datum/design/skills_hud
	name = "Skills HUD"
	desc = "A heads-up display that scans the humans in view and shows a summary of their NT employment history."
	id = "skills_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/skills
	category = list("Equipment")

/datum/design/jani_hud
	name = "Janitor HUD"
	desc = "A heads-up display that scans for messes and alerts the user. Good for finding puddles hiding under catwalks."
	id = "jani_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/janitor
	category = list("Equipment", "Janitorial")

/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used for seeing walls, floors, and stuff through anything."
	id = "mesons"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/meson
	category = list("Equipment")


/datum/design/engine_goggles
	name = "Engineering Scanner Goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, regardless of lighting condition. The T-ray Scanner mode lets you see underfloor objects such as cables and pipes."
	id = "engine_goggles"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_PLASMA = 100)
	build_path = /obj/item/clothing/glasses/meson/engine
	category = list("Equipment")

/datum/design/atmos_goggles
	name = "Atmospherics Scanner Goggles"
	desc = "Used by atmospherics techs to see pressure and underfloor objects such as cables and pipes."
	id = "atmos_goggles"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/meson/engine/atmos
	category = list("Equipment")

/datum/design/nvgmesons
	name = "Night Vision Optical Meson Scanners"
	desc = "Prototype meson scanners fitted with an extra sensor which amplifies the visible light spectrum and overlays it to the UHD display."
	id = "nvgmesons"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_PLASMA = 350, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/meson/night
	category = list("Equipment")

/datum/design/air_horn
	name = "Air Horn"
	desc = "Damn son, where'd you find this?"
	id = "air_horn"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_BANANIUM = 1000)
	build_path = /obj/item/bikehorn/airhorn
	category = list("Equipment")

/datum/design/breath_mask
	name = "Breath Mask"
	desc = "A close-fitting mask that can be connected to an air supply."
	id = "breathmask"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 200)
	build_path = /obj/item/clothing/mask/breath
	category = list("Equipment")

/datum/design/welding_mask
	name = "Welding Gas Mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	id = "weldingmask"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000)
	build_path = /obj/item/clothing/mask/gas/welding
	category = list("Equipment")

/datum/design/portaseeder
	name = "Portable Seed Extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	build_type = PROTOLATHE
	id = "portaseeder"
	materials = list(MAT_METAL = 1000, MAT_GLASS = 400)
	build_path = /obj/item/storage/bag/plants/portaseeder
	category = list("Equipment")

/datum/design/sci_goggles
	name = "Science Goggles"
	desc = "Goggles fitted with a portable analyzer capable of determining the research worth of an item or components of a machine."
	id = "scigoggles"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/science
	category = list("Equipment")

/datum/design/diagnostic_hud
	name = "Diagnostic HUD"
	desc = "A HUD used to analyze and determine faults within robotic machinery."
	id = "dianostic_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/diagnostic
	category = list("Equipment")

/datum/design/hydroponic_hud
	name = "Hydroponic HUD"
	desc = "A HUD used to analyze the health and status of plants growing in hydro trays and soil."
	id = "hydroponic_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/hydroponic
	category = list("Equipment")

/datum/design/handdrill
	name = "Hand Drill"
	desc = "A small electric hand drill with an interchangable screwdriver and bolt bit."
	id = "handdrill"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3500, MAT_SILVER = 1500, MAT_TITANIUM = 2500)
	build_path = /obj/item/screwdriver/power
	category = list("Equipment")

/datum/design/jawsoflife
	name = "Jaws of Life"
	desc = "A small, compact Jaws of Life with an interchangable pry jaws and cutting jaws."
	id = "jawsoflife"
	build_path = /obj/item/crowbar/power
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 2500, MAT_TITANIUM = 3500)
	category = list("Equipment")

/datum/design/minicrowbar
	name = "Miniature Titanium Crowbar"
	desc = "A lightweight and portable version of the Crowbar that fits into smaller storages."
	id = "minicrowbar"
	build_path = /obj/item/crowbar/small
	build_type = PROTOLATHE
	materials = list(MAT_TITANIUM = 250)
	category = list("Equipment")

/datum/design/alienwrench
	name = "Alien Wrench"
	desc = "An advanced wrench obtained through Abductor technology."
	id = "alien_wrench"
	build_path = /obj/item/wrench/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/alienwirecutters
	name = "Alien Wirecutters"
	desc = "Advanced wirecutters obtained through Abductor technology."
	id = "alien_wirecutters"
	build_path = /obj/item/wirecutters/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/alienscrewdriver
	name = "Alien Screwdriver"
	desc = "An advanced screwdriver obtained through Abductor technology."
	id = "alien_screwdriver"
	build_path = /obj/item/screwdriver/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/aliencrowbar
	name = "Alien Crowbar"
	desc = "An advanced crowbar obtained through Abductor technology."
	id = "alien_crowbar"
	build_path = /obj/item/crowbar/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/alienwelder
	name = "Alien Welding Tool"
	desc = "An advanced welding tool obtained through Abductor technology."
	id = "alien_welder"
	build_path = /obj/item/weldingtool/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 5000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/alienmultitool
	name = "Alien Multitool"
	desc = "An advanced multitool obtained through Abductor technology."
	id = "alien_multitool"
	build_path = /obj/item/multitool/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 5000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/bluespace_closet
	name = "Bluespace Closet"
	desc = "A storage unit that moves and stores through the fourth dimension."
	id = "bluespace_closet"
	build_path = /obj/structure/closet/bluespace
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_PLASMA = 2500, MAT_TITANIUM = 500, MAT_BLUESPACE = 500)
	category = list("Equipment")

/datum/design/gravboots
	name = "Gravitational Boots"
	desc = "Experimental magboots that use miniture gravity generators instead."
	id = "gravboots"
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 4000, MAT_TITANIUM = 6000, MAT_URANIUM = 4000, MAT_PLASMA = 4000)
	build_path = /obj/item/clothing/shoes/magboots/gravity
	category = list("Equipment")

/datum/design/bolterwrench
	name = "Door Bolt Wrench"
	desc = "A large wrench designed to interlock with an airlock's bolting mechanisms, allowing it to lift the bolts regardless of power."
	id = "bolter_wrench"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_TITANIUM = 3000)
	build_path = /obj/item/wrench/bolter
	category = list("Equipment")
