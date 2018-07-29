/////////////////////////////////////////
////////////Power Designs////////////////
/////////////////////////////////////////

/datum/design/basic_cell
	name = "Basic Power Cell"
	desc = "A basic power cell that holds 1 kW of power."
	id = "basic_cell"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 50)
	construction_time=100
	build_path = /obj/item/stock_parts/cell
	category = list("Misc","Power","Machinery","initial")

/datum/design/high_cell
	name = "High-Capacity Power Cell"
	desc = "A power cell that holds 10 kW of power."
	id = "high_cell"
	req_tech = list("powerstorage" = 2)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 60)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/high
	category = list("Misc","Power")

/datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	desc = "A power cell that holds 30 kW of power."
	id = "hyper_cell"
	req_tech = list("powerstorage" = 5, "materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_METAL = 700, MAT_GOLD = 150, MAT_SILVER = 150, MAT_GLASS = 70)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/hyper
	category = list("Misc","Power")

/datum/design/super_cell
	name = "Super-Capacity Power Cell"
	desc = "A power cell that holds 20 kW of power."
	id = "super_cell"
	req_tech = list("powerstorage" = 3, "materials" = 3)
	build_type = PROTOLATHE | MECHFAB | PODFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 70)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/super
	category = list("Misc","Power")

/datum/design/bluespace_cell
	name = "Bluespace Power Cell"
	desc = "A power cell that holds 40 kW of power."
	id = "bluespace_cell"
	req_tech = list("powerstorage" = 6, "materials" = 5, "engineering" = 5, "bluespace" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 800, MAT_GOLD = 120, MAT_GLASS = 160, MAT_DIAMOND = 160, MAT_TITANIUM = 300, MAT_BLUESPACE = 100)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/bluespace
	category = list("Misc","Power")

/datum/design/pacman
	name = "Machine Board (PACMAN-type Generator)"
	desc = "The circuit board that for a PACMAN-type portable generator."
	id = "pacman"
	req_tech = list("programming" = 2, "plasmatech" = 3, "powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/pacman
	category = list("Engineering Machinery")

/datum/design/mrspacman
	name = "Machine Board (MRSPACMAN-type Generator)"
	desc = "The circuit board that for a MRSPACMAN-type portable generator."
	id = "mrspacman"
	req_tech = list("programming" = 3, "powerstorage" = 5, "engineering" = 5, "plasmatech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/pacman/mrs
	category = list("Engineering Machinery")

/datum/design/superpacman
	name = "Machine Board (SUPERPACMAN-type Generator)"
	desc = "The circuit board that for a SUPERPACMAN-type portable generator."
	id = "superpacman"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/pacman/super
	category = list("Engineering Machinery")

/datum/design/tesla_coil
	name = "Machine Design (Tesla Coil Board)"
	desc = "The circuit board for a tesla coil."
	id = "tesla_coil"
	req_tech = list("programming" = 3, "powerstorage" = 3, "magnets" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/tesla_coil
	category = list("Engineering Machinery")

/datum/design/grounding_rod
	name = "Machine Design (Grounding Rod Board)"
	desc = "The circuit board for a grounding rod."
	id = "grounding_rod"
	req_tech = list("programming" = 3, "powerstorage" = 3, "magnets" = 3, "plasmatech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/grounding_rod
	category = list("Engineering Machinery")
