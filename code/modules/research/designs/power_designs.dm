/////////////////////////////////////////
////////////Power Designs////////////////
/////////////////////////////////////////

/datum/design/basic_cell
	name = "Basic Power Cell"
	desc = "A basic power cell that holds 1 kW of power."
	id = "basic_cell"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 50)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/empty
	category = list("Misc", "Power", "Stock Parts", "Machinery", "initial")

/datum/design/high_cell
	name = "High-Capacity Power Cell"
	desc = "A power cell that holds 10 kW of power."
	id = "high_cell"
	req_tech = list("powerstorage" = 2)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 60)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/high/empty
	category = list("Misc", "Power", "Stock Parts")

/datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	desc = "A power cell that holds 30 kW of power."
	id = "hyper_cell"
	req_tech = list("powerstorage" = 5, "materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GOLD = 150, MAT_SILVER = 150, MAT_GLASS = 400)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/hyper/empty
	category = list("Misc", "Power", "Stock Parts")

/datum/design/super_cell
	name = "Super-Capacity Power Cell"
	desc = "A power cell that holds 20 kW of power."
	id = "super_cell"
	req_tech = list("powerstorage" = 3, "materials" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 300)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/super/empty
	category = list("Misc", "Power", "Stock Parts")

/datum/design/bluespace_cell
	name = "Bluespace Power Cell"
	desc = "A power cell that holds 40 kW of power."
	id = "bluespace_cell"
	req_tech = list("powerstorage" = 6, "materials" = 5, "engineering" = 5, "bluespace" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 800, MAT_GOLD = 120, MAT_GLASS = 600, MAT_DIAMOND = 160, MAT_TITANIUM = 300, MAT_BLUESPACE = 100)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/bluespace/empty
	category = list("Misc", "Power", "Stock Parts")

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

/datum/design/centrifuge
	name = "Machine Design (Nuclear Centrifuge Board)"
	desc = "The circuit board for a nuclear centrifuge."
	id = "nuclear_centrifuge"
	req_tech = list("programming" = 3, "materials" = 5, "magnets" = 5, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GOLD = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/nuclear_centrifuge
	category = list("Power", "Engineering Machinery")

/datum/design/rod_fabricator
	name = "Machine Design (Nuclear Rod Fabricator Board)"
	desc = "The circuit board for a nuclear rod fabricator."
	id = "nuclear_fabricator"
	req_tech = list("programming" = 5, "materials" = 5, "magnets" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GOLD = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/nuclear_rod_fabricator
	category = list("Power", "Engineering Machinery")

/datum/design/nuclear_gas_node
	name = "Machine Design (Nuclear Gas Node Board)"
	desc = "The circuit board for a nuclear gas node."
	id = "nuclear_gas_node"
	req_tech = list("programming" = 4, "materials" = 4, "magnets" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GOLD = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/machine/reactor_gas_node
	category = list("Power", "Engineering Machinery")

/datum/design/rod_fabricator_upgrade
	name = "Nuclear Rod Fabricator Upgrade"
	desc = "A design disk containing a dizzying amount of designs and improvements for nuclear rod fabrication."
	id = "nuclear_fab_upgrade"
	req_tech = list("programming" = 5, "materials" = 5, "magnets" = 4, "plasmatech" = 3, "toxins" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000, MAT_URANIUM = 500, MAT_GOLD = 400)
	build_path = /obj/item/rod_fabricator_upgrade
	category = list("Power", "Engineering Machinery", "Misc")

/datum/design/reactor_chamber
	name = "Machine Design (Reactor Chamber Board)"
	desc = "A chamber used to house nuclear rods of various types to facilitate a fission reaction."
	id = "reactor_chamber"
	req_tech = list("programming" = 4, "materials" = 4, "magnets" = 4, "plasmatech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000)
	build_path = /obj/item/circuitboard/machine/reactor_chamber
	category = list("Power", "Engineering Machinery", "Misc")

/datum/design/neutron_grenade
	name = "Neutron Agitator Grenade"
	desc = "A throwable device capable of inducing an artificial startup in rod chambers."
	id = "neutron_grenade"
	req_tech = list("materials" = 6, "magnets" = 5, "plasmatech" = 5, "toxins" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GOLD = 2000)
	build_path = /obj/item/grenade/nuclear_starter
	category = list("Power", "Misc")

