/datum/design/board/podfab
	name = "Space Pod Fabricator Board"
	desc = "The circuit board for an Space Pod Fabricator."
	id = "spacefab"
	build_path = /obj/item/circuitboard/podfabricator
	build_type = IMPRINTER
	req_tech = list("programming" = 2)
	materials = list(MAT_GLASS = 1000)
	category = list("Computer Boards")

/datum/design/spacepodbase
	name = "Space Pod Hull"
	desc = "The body of the Space Pod, the basis for the rest of the parts."
	id = "spacepod_basic"
	req_tech = list("materials" = 1, "magnets" = 1)
	build_path = /obj/item/pods_parts/hull
	build_type = PROTOLATHE
	materials = list(
		MAT_METAL = 15000,
		MAT_GLASS = 10000,
		MAT_SILVER = 5000,
		MAT_GOLD = 1000,
	)
	category = list("Space Pods")

/datum/design/spacepod_main
	name = "Space Pod Central Control module"
	desc = "Allows for the construction of a \"Raptor\" Central Control module."
	id = "raptor_main"
	req_tech = list("programming" = 1)
	build_path = /obj/item/circuitboard/mecha/spacepod_main
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 5000)
	category = list("Space Pod Boards")

/datum/design/spacepod_peri
	name = "Space Pod Peripherals Control module"
	desc = "Allows for the construction of a \"Raptor\" Peripheral Control module."
	id = "raptor_peri"
	req_tech = list("programming" = 1)
	build_path = /obj/item/circuitboard/mecha/spacepod_peri
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 3000)
	category = list("Space Pod Boards")

/datum/design/plate_basic
	name = "Space Pod Standard Plate"
	desc = "The Standard Armor Plate of the Space Pod."
	id = "spacepod_plate_basic"
	build_path = /obj/item/pods_parts/plate/basic
	build_type = PROTOLATHE
	req_tech = list("materials" = 1)
	materials = list(MAT_METAL = 2000)
	construction_time = 100
	category = list("Space Pods")

/datum/design/plate_sci
	name = "Space Pod Explorer Plate"
	desc = "The Science Armor Plate of the Space Pod. For Vanguard!"
	id = "spacepod_plate_sci"
	build_path = /obj/item/pods_parts/plate/sci
	build_type = PROTOLATHE
	req_tech = list("materials" = 2)
	materials = list(MAT_METAL = 3000)
	construction_time = 100
	category = list("Space Pods")

/datum/design/plate_sec
	name = "Space Pod Security Plate"
	desc = "The Science Armor Plate of the Space Pod. For Vanguard!"
	id = "spacepod_plate_sec"
	build_path = /obj/item/pods_parts/plate/sec
	build_type = PROTOLATHE
	req_tech = list("materials" = 4)
	materials = list(
		MAT_METAL = 2000,
		MAT_TITANIUM = 1000,
	)
	construction_time = 100
	category = list("Space Pods")
