/datum/design/telepad
	name = "Machine Board (Telepad Board)"
	desc = "Allows for the construction of circuit boards used to build a Telepad."
	id = "telepad"
	req_tech = list("programming" = 6, "bluespace" = 8, "plasmatech" = 6, "engineering" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telesci_pad
	category = list ("Teleportation Machinery")
