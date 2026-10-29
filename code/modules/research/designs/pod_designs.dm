/datum/design/board/podfab
	name = "Space Pod Fabricator Board"
	desc = "The circuit board for an Space Pod Fabricator."
	id = "spacefab"
	build_path = /obj/item/circuitboard/podfabricator
	build_type = IMPRINTER
	req_tech = list("programming" = 2)
	materials = list(
		MAT_GLASS = MINERAL_MATERIAL_AMOUNT * 5,
	)
	category = list("Computer Boards")

/datum/design/space_pod_wing
	name = "Space Pod Wing"
	category = list("Space Pods")
	build_path = /obj/item/spacepod_part/wing
	build_type = PROTOLATHE
	id = "spacepods_parts_wing"
	req_tech = list("materials" = 1, "magnets" = 1)
	materials = list(
		MAT_METAL = MINERAL_MATERIAL_AMOUNT * 10,
	)

/datum/design/space_pod_frame
	name = "Space Pod Frame"
	category = list("Space Pods")
	build_path = /obj/item/spacepod_part/frame
	build_type = PROTOLATHE
	id = "spacepods_parts_frame"
	req_tech = list("materials" = 1, "magnets" = 1)
	materials = list(
		MAT_METAL = MINERAL_MATERIAL_AMOUNT * 10,
		MAT_PLASMA = MINERAL_MATERIAL_AMOUNT * 10,
	)

/datum/design/space_pod_nacelle
	name = "Space Pod Nacelle"
	category = list("Space Pods")
	build_path = /obj/item/spacepod_part/nacelle
	build_type = PROTOLATHE
	id = "spacepods_parts_nacelle"
	req_tech = list("materials" = 1, "magnets" = 1)
	materials = list(
		MAT_METAL = MINERAL_MATERIAL_AMOUNT * 10,
	)

/datum/design/space_pod_cockpit
	name = "Space Pod Cockpit"
	category = list("Space Pods")
	build_path = /obj/item/spacepod_part/cockpit
	build_type = PROTOLATHE
	id = "spacepods_parts_cockpit"
	req_tech = list("materials" = 1, "magnets" = 1)
	materials = list(
		MAT_METAL = MINERAL_MATERIAL_AMOUNT * 10,
	)

/datum/design/space_pod_engine
	name = "Space Pod Engine"
	category = list("Space Pods")
	build_path = /obj/item/spacepod_part/engine
	build_type = PROTOLATHE
	id = "spacepods_parts_engine"
	req_tech = list("materials" = 1, "magnets" = 1)
	materials = list(
		MAT_PLASMA = MINERAL_MATERIAL_AMOUNT * 10,
		MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT * 10,
	)

/datum/design/spacepod_main
	name = "Space Pod Central Control module"
	desc = "Allows for the construction of a \"Raptor\" Central Control module."
	id = "raptor_main"
	req_tech = list("programming" = 1)
	build_path = /obj/item/circuitboard/mecha/spacepod_main
	build_type = IMPRINTER
	materials = list(
		MAT_GLASS = MINERAL_MATERIAL_AMOUNT * 5,
	)
	category = list("Space Pod Boards")

/datum/design/spacepod_peri
	name = "Space Pod Peripherals Control module"
	desc = "Allows for the construction of a \"Raptor\" Peripheral Control module."
	id = "raptor_peri"
	req_tech = list("programming" = 1)
	build_path = /obj/item/circuitboard/mecha/spacepod_peri
	build_type = IMPRINTER
	materials = list(
		MAT_GLASS = MINERAL_MATERIAL_AMOUNT * 5,
	)
	category = list("Space Pod Boards")

/datum/design/plate_basic
	name = "Space Pod Standard Plate"
	desc = "The Standard Armor Plate of the Space Pod."
	id = "spacepod_plate_basic"
	build_path = /obj/item/spacepod_plate
	build_type = PROTOLATHE
	req_tech = list("materials" = 1)
	materials = list(
		MAT_METAL = MINERAL_MATERIAL_AMOUNT * 5,
	)
	construction_time = 100
	category = list("Space Pods")

/datum/design/plate_sci
	name = "Space Pod Explorer Plate"
	desc = "The Science Armor Plate of the Space Pod. For Vanguard!"
	id = "spacepod_plate_sci"
	build_path = /obj/item/spacepod_plate/sci
	build_type = PROTOLATHE
	req_tech = list("materials" = 2)
	materials = list(
		MAT_METAL = MINERAL_MATERIAL_AMOUNT * 10,
	)
	construction_time = 100
	category = list("Space Pods")

/datum/design/plate_sec
	name = "Space Pod Security Plate"
	desc = "The Science Armor Plate of the Space Pod. For Vanguard!"
	id = "spacepod_plate_sec"
	build_path = /obj/item/spacepod_plate/sec
	build_type = PROTOLATHE
	req_tech = list("materials" = 4)
	materials = list(
		MAT_METAL = MINERAL_MATERIAL_AMOUNT * 10,
		MAT_TITANIUM = MINERAL_MATERIAL_AMOUNT * 10,
	)
	construction_time = 100
	category = list("Space Pods")
