/datum/design/telepad
	name = "Machine Board (Telepad Board)"
	desc = "Allows for the construction of circuit boards used to build a Telepad."
	id = "telepad"
	req_tech = list("programming" = 4, "bluespace" = 5, "plasmatech" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telesci_pad
	category = list ("Teleportation Machinery")
