/datum/design/welding_goggles
	name = "Welding Goggles"
	desc = "Protects the eyes from bright flashes; approved by the mad scientist association."
	id = "welding_goggles"
	build_type = PROTOLATHE
	req_tech = list("magnets" = 2, "engineering" = 2, "plasmatech" = 2)
	materials = list(MAT_METAL = 300, MAT_GLASS = 350)
	build_path = /obj/item/clothing/glasses/welding
	category = list("Equipment")

/datum/design/tray_goggles
	name = "Optical T-Ray Scanners"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	id = "tray_goggles"
	build_type = PROTOLATHE
	req_tech = list("magnets" = 3, "engineering" = 3, "plasmatech" = 3)
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/glasses/meson/engine/tray
	category = list("Equipment")

/datum/design/engine_goggles
	name = "Engineering Scanner Goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, regardless of lighting condition. The T-ray Scanner mode lets you see underfloor objects such as cables and pipes."
	id = "engine_goggles"
	build_type = PROTOLATHE
	req_tech = list("materials" = 3, "magnets" = 4, "engineering" = 5, "plasmatech" = 4)
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_PLASMA = 250)
	build_path = /obj/item/clothing/glasses/meson/engine
	category = list("Equipment")

/datum/design/reactive_armour
	name = "Reactive Armour Shell"
	desc = "An experimental suit of armour capable of utilizing an implanted anomaly core to protect the user."
	id = "reactive_armour"
	build_type = PROTOLATHE
	req_tech = list("materials" = 7, "engineering" = 7, "plasmatech" = 7, "magnets" = 7, "toxins" = 7, "combat" = 7, "bluespace" = 7)
	materials = list(MAT_METAL = 10000, MAT_DIAMOND = 5000, MAT_URANIUM = 8000, MAT_SILVER = 4500, MAT_GOLD = 5000, MAT_PLASMA = 2500)
	build_path = /obj/item/reactive_armour_shell
	access_requirement = list(ACCESS_RD)
	category = list("Equipment")

/datum/design/jet_upgrade
	name = "Jetpack Hardsuit Upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with a hardsuit."
	id = "jet_upgrade"
	build_type = PROTOLATHE
	req_tech = list("magnets" = 5, "engineering" = 6, "plasmatech" = 5)
	materials = list(MAT_METAL = 10000, MAT_DIAMOND = 5000, MAT_SILVER = 4500, MAT_GOLD = 5000, MAT_PLASMA = 2500)
	build_path = /obj/item/tank/jetpack/suit
	category = list("Equipment")
