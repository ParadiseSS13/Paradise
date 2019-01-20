/////////////////////////////////////////
/////////////////Equipment///////////////
/////////////////////////////////////////
/datum/design/exwelder
	name = "Experimental Welding Tool"
	desc = "An experimental welder capable of self-fuel generation."
	id = "exwelder"
	req_tech = list("materials" = 4, "engineering" = 5, "bluespace" = 3, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_PLASMA = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/weldingtool/experimental
	category = list("Equipment")

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list("Equipment")

/datum/design/health_hud_night
	name = "Night Vision Health Scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	id = "health_hud_night"
	req_tech = list("biotech" = 4, "magnets" = 5, "plasmatech" = 4, "engineering" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_SILVER = 350)
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
	req_tech = list("materials" = 4, "magnets" = 5, "plasmatech" = 4, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_PLASMA = 350, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/night
	category = list("Equipment")

/datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/security
	category = list("Equipment")

/datum/design/security_hud_night
	name = "Night Vision Security HUD"
	desc = "A heads-up display which provides id data and vision in complete darkness."
	id = "security_hud_night"
	req_tech = list("combat" = 4, "magnets" = 5, "plasmatech" = 4, "engineering" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_GOLD = 350)
	build_path = /obj/item/clothing/glasses/hud/security/night
	category = list("Equipment")

/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used for seeing walls, floors, and stuff through anything."
	id = "mesons"
	req_tech = list("magnets" = 2, "engineering" = 2, "plasmatech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/meson
	category = list("Equipment")

/datum/design/nvgmesons
	name = "Night Vision Optical Meson Scanners"
	desc = "Prototype meson scanners fitted with an extra sensor which amplifies the visible light spectrum and overlays it to the UHD display."
	id = "nvgmesons"
	req_tech = list("magnets" = 5, "plasmatech" = 5, "engineering" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_PLASMA = 350, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/meson/night
	category = list("Equipment")

/datum/design/air_horn
	name = "Air Horn"
	desc = "Damn son, where'd you find this?"
	id = "air_horn"
	req_tech = list("materials" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_BANANIUM = 1000)
	build_path = /obj/item/bikehorn/airhorn
	category = list("Equipment")

/datum/design/breath_mask
	name = "Breath mask"
	desc = "A close-fitting mask that can be connected to an air supply."
	id = "breathmask"
	req_tech = list("toxins" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 200)
	build_path = /obj/item/clothing/mask/breath
	category = list("Equipment")

/datum/design/welding_mask
	name = "Welding Gas Mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	id = "weldingmask"
	req_tech = list("materials" = 2, "engineering" = 3, "toxins" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000)
	build_path = /obj/item/clothing/mask/gas/welding
	category = list("Equipment")

/datum/design/portaseeder
	name = "Portable Seed Extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	build_type = PROTOLATHE
	req_tech = list("biotech" = 3, "engineering" = 2)
	materials = list(MAT_METAL = 1000, MAT_GLASS = 400)
	build_path = /obj/item/storage/bag/plants/portaseeder
	category = list("Equipment")

/datum/design/sci_goggles
	name = "Science Goggles"
	desc = "Goggles fitted with a portable analyzer capable of determining the research worth of an item or components of a machine."
	id = "scigoggles"
	req_tech = list("magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/science
	category = list("Equipment")

/datum/design/nv_sci_goggles
	name = "Night Vision Science Goggles"
	desc = "Like Science Goggles, but works in darkness."
	id = "nvscigoggles"
	req_tech = list("magnets" = 5, "plasmatech" = 4, "engineering" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 300, MAT_PLASMA = 250, MAT_URANIUM = 1000)
	build_path = /obj/item/clothing/glasses/science/night
	category = list("Equipment")

/datum/design/diagnostic_hud
	name = "Diagnostic HUD"
	desc = "A HUD used to analyze and determine faults within robotic machinery."
	id = "dianostic_hud"
	req_tech = list("magnets" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/diagnostic
	category = list("Equipment")

/datum/design/diagnostic_hud_night
	name = "Night Vision Diagnostic HUD"
	desc = "Upgraded version of the diagnostic HUD designed to function during a power failure."
	id = "dianostic_hud_night"
	req_tech = list("magnets" = 5, "plasmatech" = 4, "engineering" = 6, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_URANIUM = 1000, MAT_PLASMA = 300)
	build_path = /obj/item/clothing/glasses/hud/diagnostic/night
	category = list("Equipment")

/datum/design/hydroponic_hud
	name = "Hydroponic HUD"
	desc = "A HUD used to analyze the health and status of plants growing in hydro trays and soil."
	id = "hydroponic_hud"
	req_tech = list("magnets" = 3, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/hydroponic
	category = list("Equipment")

/datum/design/hydroponic_hud_night
	name = "Night Vision Hydroponic HUD"
	desc = "A HUD used to analyze the health and status of plants growing in low-light environments."
	id = "hydroponic_hud_night"
	req_tech = list("biotech" = 4, "magnets" = 5, "plasmatech" = 4, "engineering" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_URANIUM = 1000, MAT_PLASMA = 200)
	build_path = /obj/item/clothing/glasses/hud/hydroponic/night
	category = list("Equipment")

/datum/design/handdrill
	name = "Hand Drill"
	desc = "A small electric hand drill with an interchangable screwdriver and bolt bit"
	id = "handdrill"
	req_tech = list("materials" = 4, "engineering" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3500, MAT_SILVER = 1500, MAT_TITANIUM = 2500)
	build_path = /obj/item/screwdriver/power
	category = list("Equipment")

/datum/design/jawsoflife
	name = "Jaws of Life"
	desc = "A small, compact Jaws of Life with an interchangable pry jaws and cutting jaws"
	id = "jawsoflife"
	req_tech = list("materials" = 4, "engineering" = 6, "magnets" = 6) // added one more requirment since the Jaws of Life are a bit OP
	build_path = /obj/item/crowbar/power
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 2500, MAT_TITANIUM = 3500)
	category = list("Equipment")

/datum/design/alienwrench
	name = "Alien Wrench"
	desc = "An advanced wrench obtained through Abductor technology."
	id = "alien_wrench"
	req_tech = list("engineering" = 5, "materials" = 5, "abductor" = 4)
	build_path = /obj/item/wrench/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/alienwirecutters
	name = "Alien Wirecutters"
	desc = "Advanced wirecutters obtained through Abductor technology."
	id = "alien_wirecutters"
	req_tech = list("engineering" = 5, "materials" = 5, "abductor" = 4)
	build_path = /obj/item/wirecutters/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/alienscrewdriver
	name = "Alien Screwdriver"
	desc = "An advanced screwdriver obtained through Abductor technology."
	id = "alien_screwdriver"
	req_tech = list("engineering" = 5, "materials" = 5, "abductor" = 4)
	build_path = /obj/item/screwdriver/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/aliencrowbar
	name = "Alien Crowbar"
	desc = "An advanced crowbar obtained through Abductor technology."
	id = "alien_crowbar"
	req_tech = list("engineering" = 5, "materials" = 5, "abductor" = 4)
	build_path = /obj/item/crowbar/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/alienwelder
	name = "Alien Welding Tool"
	desc = "An advanced welding tool obtained through Abductor technology."
	id = "alien_welder"
	req_tech = list("engineering" = 5, "plasmatech" = 5, "abductor" = 4)
	build_path = /obj/item/weldingtool/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 5000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/alienmultitool
	name = "Alien Multitool"
	desc = "An advanced multitool obtained through Abductor technology."
	id = "alien_multitool"
	req_tech = list("engineering" = 5, "programming" = 5, "abductor" = 4)
	build_path = /obj/item/multitool/abductor
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2500, MAT_PLASMA = 5000, MAT_TITANIUM = 2000, MAT_DIAMOND = 2000)
	category = list("Equipment")

/datum/design/bluespace_closet
	name = "Bluespace Closet"
	desc = "A storage unit that moves and stores through the fourth dimension."
	id = "bluespace_closet"
	req_tech = list("engineering" = 4, "programming" = 5, "bluespace" = 5, "magnets" = 4, "plasmatech" = 3)
	build_path = /obj/structure/closet/bluespace
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_PLASMA = 2500, MAT_TITANIUM = 500, MAT_BLUESPACE = 500)
	category = list("Equipment")
