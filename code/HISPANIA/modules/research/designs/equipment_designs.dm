/datum/design/tray_goggles
	name = "Optical T-Ray Scanners"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	id = "tray_goggles"
	req_tech = list("magnets" = 3, "engineering" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
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
