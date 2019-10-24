/datum/design/telesci_console
	name = "Console Board (Telepad Control Console)"
	desc = "Allows for the construction of circuit boards used to build a telescience console."
	id = "telesci_console"
	req_tech = list("programming" = 5, "bluespace" = 8, "plasmatech" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telesci_console
	category = list("Computer Boards")
