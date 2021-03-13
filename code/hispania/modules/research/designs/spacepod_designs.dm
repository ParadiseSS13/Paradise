//////////////////////////////////////////
//////SPACEPOD GUNS///////////////////////
//////////////////////////////////////////
/datum/design/pod_plasmacutterpod
	construction_time = 200
	name = "Plasma Cutter System"
	desc = "Allows for the construction of a plasma cutter system for dual fire."
	id = "pod_plasmacutterpod"
	req_tech = list("engineering" = 4, "materials" = 5, "plasmatech" = 4)
	build_type = PODFAB
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2000, MAT_PLASMA = 6000)
	build_path = /obj/item/spacepod_equipment/weaponry/plasmacutterpod
	category = list("Pod_Weaponry")

/datum/design/pod_inmolationpod
	construction_time = 200
	name = "ZFI Immolation Beam System (Fire-Laser)"
	desc = "Allows for the construction of a spacepod mounted ZFI Immolation Beam System."
	id = "pod_inmolationpod"
	build_type = PODFAB
	req_tech = list("combat" = 6, "magnets" = 5, "materials" = 5)
	build_path = /obj/item/spacepod_equipment/weaponry/inmolationpod
	category = list("Pod_Weaponry")
	materials = list(MAT_METAL = 10000, MAT_SILVER = 8000, MAT_PLASMA = 8000)
	locked = TRUE

/datum/design/pod_ionsystempod
	construction_time = 200
	name = "Ion Breach System"
	desc = "Allows for the construction of a spacepod mounted Ion Breach System."
	id = "pod_ionsystempod"
	build_type = PODFAB
	req_tech = list("combat" = 6, "magnets" = 5, "materials" = 5, "engineering" = 4)
	build_path = /obj/item/spacepod_equipment/weaponry/ionsystempod
	category = list("Pod_Weaponry")
	materials = list(MAT_METAL=20000,MAT_SILVER=6000,MAT_URANIUM=2000)
	locked = TRUE

/datum/design/lmgpod
	construction_time = 200
	name = "LMG System"
	desc = "Allows for the construction of a spacepod mounted LMG System."
	id = "pod_lmgsystempod"
	build_type = PODFAB
	req_tech = list("combat" = 7)
	build_path = /obj/item/spacepod_equipment/weaponry/lmgpod
	category = list("Pod_Weaponry")
	materials = list(MAT_METAL=10000)
	locked = TRUE

//////////////////////////////////////////
//////SPACEPOD MISC. ITEMS////////////////
//////////////////////////////////////////


//////////////////////////////////////////
//////SPACEPOD CARGO ITEMS////////////////
//////////////////////////////////////////

/datum/design/pod_chair_triple
	construction_time = 100
	name = "Spacepod Dual Passenger Seat"
	desc = "Allows the construction of a Space Pod Passenger Seat Module for Two more people."
	id = "pod_chair_triple"
	req_tech = list("materials" = 5, "engineering" = 4)
	build_type = PODFAB
	materials = list(MAT_METAL=20000, MAT_GLASS=2000)
	build_path = /obj/item/spacepod_equipment/sec_cargo/chair_triple
	category = list("Pod_Cargo")

/datum/design/chair_cuadro
	construction_time = 100
	name = "Spacepod Triple Passenger Seat"
	desc = "Allows the construction of a Space Pod Passenger Seat Module for Three more people."
	id = "chair_cuadro"
	req_tech = list("materials" = 7, "engineering" = 4)
	build_type = PODFAB
	materials = list(MAT_METAL=20000, MAT_GLASS=2000)
	build_path = /obj/item/spacepod_equipment/sec_cargo/chair_cuadro
	category = list("Pod_Cargo")

//////////////////////////////////////////
//////SPACEPOD SEC CARGO ITEMS////////////
//////////////////////////////////////////

/datum/design/bs_loot_box
	construction_time = 100
	name = "Spacepod Loot Storage Module Bluespace Version"
	desc = "Allows the construction of a Space Pod Auxillary Cargo Module Bluespace Version."
	id = "bs_loot_box"
	req_tech = list("bluespace" = 7, "magnets" = 6) //it's just a set of shelves, It's not that hard to make
	build_type = PODFAB
	materials = list(MAT_METAL=10000,MAT_GLASS=5000,MAT_GOLD=1000,MAT_SILVER=2000,MAT_BLUESPACE = 1000)
	build_path = /obj/item/spacepod_equipment/sec_cargo/bs_loot_box
	category = list("Pod_Cargo")
