/datum/design/telesci_console
	name = "Console Board (Telepad Control Console)"
	desc = "Allows for the construction of circuit boards used to build a telescience console."
	id = "telesci_console"
	req_tech = list("programming" = 6, "bluespace" = 8, "plasmatech" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telesci_console
	category = list("Computer Boards")

/datum/design/prototelesci_console
	name = "Console Board (Proto Telepad Control Console)"
	desc = "Allows for the construction of circuit boards used to build a proto telescience console."
	id = "proto_telesci_console"
	req_tech = list("programming" = 4, "bluespace" = 4, "plasmatech" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telesci_console/proto
	category = list("Computer Boards")

