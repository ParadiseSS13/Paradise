////////////////////////////////////////
// MARK: Misc Designs
////////////////////////////////////////

/datum/design/magboots
	name = "Magnetic Boots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	id = "magboots"
	req_tech = list("materials" = 4, "magnets" = 4, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list("Equipment")

/datum/design/gravboots
	name = "Gravitational Boots"
	desc = "Experimental magboots that use miniture gravity generators instead."
	id = "gravboots"
	req_tech = list("materials" = 7, "magnets" = 7, "engineering" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_SILVER = 4000, MAT_TITANIUM = 6000, MAT_URANIUM = 4000, MAT_PLASMA = 4000)
	build_path = /obj/item/clothing/shoes/magboots/gravity
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
	name = "Breath Mask"
	desc = "A close-fitting mask that can be connected to an air supply."
	id = "breathmask"
	req_tech = list("toxins" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 200)
	build_path = /obj/item/clothing/mask/breath
	category = list("Equipment")

////////////////////////////////////////
// MARK: Eyewear Designs
////////////////////////////////////////

/datum/design/welding_mask
	name = "Welding Gas Mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	id = "weldingmask"
	req_tech = list("materials" = 2, "engineering" = 3, "toxins" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000)
	build_path = /obj/item/clothing/mask/gas/welding
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

/datum/design/diagnostic_hud
	name = "Diagnostic HUD"
	desc = "A HUD used to analyze and determine faults within robotic machinery."
	id = "dianostic_hud"
	req_tech = list("magnets" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/diagnostic
	category = list("Equipment")

/datum/design/hydroponic_hud
	name = "Hydroponic HUD"
	desc = "A HUD used to analyze the health and status of plants growing in hydro trays and soil."
	id = "hydroponic_hud"
	req_tech = list("magnets" = 3, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/hydroponic
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

/datum/design/skills_hud
	name = "Skills HUD"
	desc = "A heads-up display that scans the humans in view and shows a summary of their NT employment history."
	id = "skills_hud"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/skills
	category = list("Equipment")

/datum/design/jani_hud
	name = "Janitor HUD"
	desc = "A heads-up display that scans for messes and alerts the user. Good for finding puddles hiding under catwalks."
	id = "jani_hud"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/janitor
	category = list("Equipment", "Janitorial")

/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used for seeing walls, floors, and stuff through anything."
	id = "mesons"
	req_tech = list("magnets" = 2, "engineering" = 2, "plasmatech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/meson
	category = list("Equipment")

/datum/design/engine_goggles
	name = "Engineering Scanner Goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, regardless of lighting condition. The T-ray Scanner mode lets you see underfloor objects such as cables and pipes."
	id = "engine_goggles"
	req_tech = list("materials" = 4, "magnets" = 3, "engineering" = 4, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_PLASMA = 100)
	build_path = /obj/item/clothing/glasses/meson/engine
	category = list("Equipment")

/datum/design/atmos_goggles
	name = "Atmospherics Scanner Goggles"
	desc = "Used by atmospherics techs to see pressure and underfloor objects such as cables and pipes."
	id = "atmos_goggles"
	req_tech = list("materials" = 3, "magnets" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/meson/engine/atmos
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

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list("Equipment")

////////////////////////////////////////
// MARK: Tools Designs
////////////////////////////////////////

/datum/design/portaseeder
	name = "Portable Seed Extractor"
	desc = "For the enterprising botanist on the go. Less efficient than the stationary model, it creates one seed per plant."
	build_type = PROTOLATHE
	id = "portaseeder"
	req_tech = list("biotech" = 3, "engineering" = 2)
	materials = list(MAT_METAL = 1000, MAT_GLASS = 400)
	build_path = /obj/item/storage/bag/plants/portaseeder
	category = list("Equipment")

/datum/design/exwelder
	name = "Experimental Welding Tool"
	desc = "An experimental welder capable of self-fuel generation."
	id = "exwelder"
	req_tech = list("materials" = 4, "engineering" = 5, "bluespace" = 3, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_PLASMA = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/weldingtool/experimental
	category = list("Equipment")

/datum/design/handdrill
	name = "Hand Drill"
	desc = "A small electric hand drill with an interchangable screwdriver and bolt bit."
	id = "handdrill"
	req_tech = list("materials" = 4, "engineering" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3500, MAT_SILVER = 1500, MAT_TITANIUM = 2500)
	build_path = /obj/item/screwdriver/power
	category = list("Equipment")

/datum/design/jawsoflife
	name = "Jaws of Life"
	desc = "A small, compact Jaws of Life with an interchangable pry jaws and cutting jaws."
	id = "jawsoflife"
	req_tech = list("materials" = 4, "engineering" = 6, "magnets" = 6) // added one more requirment since the Jaws of Life are a bit OP
	build_path = /obj/item/crowbar/power
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 2500, MAT_TITANIUM = 3500)
	category = list("Equipment")

/datum/design/minicrowbar
	name = "Miniature Titanium Crowbar"
	desc = "A lightweight and portable version of the Crowbar that fits into smaller storages."
	id = "minicrowbar"
	req_tech = list("engineering" = 4, "materials" = 3)
	build_path = /obj/item/crowbar/small
	build_type = PROTOLATHE
	materials = list(MAT_TITANIUM = 250)
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

/datum/design/bolterwrench
	name = "Door Bolt Wrench"
	desc = "A large wrench designed to interlock with an airlock's bolting mechanisms, allowing it to lift the bolts regardless of power."
	id = "bolter_wrench"
	req_tech = list("materials" = 6, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_TITANIUM = 3000)
	build_path = /obj/item/wrench/bolter
	category = list("Equipment")

////////////////////////////////////////
// MARK: Data Science Designs
////////////////////////////////////////

/datum/design/computer_basic
	name = "Basic Satellite Computer"
	desc = "A basic computer for satellites."
	id = "computer_basic"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000)
	build_path = /obj/item/satellite_component/computer/basic
	category = list("Equipment")

/datum/design/computer_efficient
	name = "Efficient Satellite Computer"
	desc = "An efficient computer for satellites. Collects less data, but is lighter."
	id = "computer_efficient"
	build_type = PROTOLATHE
	req_tech = list("programming" = 2, "engineering" = 2)
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000)
	build_path = /obj/item/satellite_component/computer/efficient
	category = list("Equipment")

/datum/design/computer_science
	name = "Scientific Satellite Computer"
	desc = "A scientific computer for satellites. Able to collect more data at once."
	id = "computer_science"
	build_type = PROTOLATHE
	req_tech = list("programming" = 3, "engineering" = 3)
	materials = list(MAT_METAL = 10000, MAT_GLASS = 6000, MAT_GOLD = 3000)
	build_path = /obj/item/satellite_component/computer/science
	category = list("Equipment")

/datum/design/basic_engine
	name = "Basic Satellite Engine"
	desc = "A basic engine for satellites."
	id = "basic_engine"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 22000)
	build_path = /obj/item/satellite_component/engine/basic_engine
	category = list("Equipment")

/datum/design/small_engine
	name = "Small Satellite Engine"
	desc = "A small engine for satellites. Less fuel capacity, but lighter."
	id = "small_engine"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 15000)
	req_tech = list("programming" = 2, "engineering" = 3)
	build_path = /obj/item/satellite_component/engine/small_engine
	category = list("Equipment")

/datum/design/ion_engine
	name = "Ion Satellite Engine"
	desc = "An ion engine for satellites. Very light and extremely fuel efficient, but uses electricity instead of generating it."
	id = "ion_engine"
	build_type = PROTOLATHE
	materials = list(MAT_TITANIUM = 20000, MAT_GOLD = 4000, MAT_PLASMA = 8000)
	req_tech = list("programming" = 4, "engineering" = 5, "plasmatech" = 4)
	build_path = /obj/item/satellite_component/engine/ion_engine
	category = list("Equipment")

/datum/design/plasma_lab
	name = "Satellite Plasma Lab"
	desc = "A plasma lab for satellites. Collects a one time sum of data."
	id = "plasma_lab"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000)
	build_path = /obj/item/satellite_component/science_instrument/plasma_lab
	category = list("Equipment")

/datum/design/meteorological_surveyor
	name = "Meteorological Surveyor"
	desc = "A meteorological surveyor for satellites. Collects data from weather phenomenon."
	id = "meteorological_surveyor"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_SILVER = 2000)
	req_tech = list("programming" = 2)
	build_path = /obj/item/satellite_component/science_instrument/meteorological_surveyor
	category = list("Equipment")

/datum/design/magnetometer
	name = "Magnetometer"
	desc = "A magnetometer for satellites. Collects data from geological phenomenon."
	id = "magnetometer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GOLD = 2000)
	req_tech = list("programming" = 2)
	build_path = /obj/item/satellite_component/science_instrument/magnetometer
	category = list("Equipment")

/datum/design/solar_panel
	name = "Satellite Solar Panel"
	desc = "A solar panel for satellites."
	id = "solar_panel"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000, MAT_SILVER = 2000)
	req_tech = list("programming" = 2, "magnets" = 2)
	build_path = /obj/item/satellite_component/misc_part/solar_panel
	category = list("Equipment")

/datum/design/radioisotope_thermoelectric_generator
	name = "Radioisotope Thermoelectric Generator"
	desc = "A solar panel for satellites. Leaks a small amount of radiation."
	id = "radioisotope_thermoelectric_generator"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_URANIUM = 10000, MAT_GOLD = 6000)
	req_tech = list("programming" = 2, "magnets" = 5, "engineering" = 5)
	build_path = /obj/item/satellite_component/misc_part/radioisotope_thermoelectric_generator
	category = list("Equipment")

/datum/design/electric_generator
	name = "Satellite Electric Generator"
	desc = "An electric generator for satellites. Uses fuel to create electricity."
	id = "electric_generator"
	build_type = PROTOLATHE
	materials = list(MAT_TITANIUM = 10000)
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_path = /obj/item/satellite_component/misc_part/electric_generator
	category = list("Equipment")

/datum/design/power_cell
	name = "Satellite Power Cell"
	desc = "A power cell for satellites."
	id = "power_cell"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_GLASS = 6000, MAT_GOLD = 2000)
	req_tech = list("programming" = 2, "magnets" = 2)
	build_path = /obj/item/satellite_component/misc_part/power_cell
	category = list("Equipment")
