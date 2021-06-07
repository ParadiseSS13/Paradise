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

/datum/design/pod_gun_blaser
	construction_time = 200
	name = "Spacepod Equipment (Burst Laser)"
	desc = "Allows for the construction of a spacepod mounted laser. This is the burst-fire model."
	id = "podgun_blaser"
	build_type = PODFAB
	req_tech = list("materials" = 4, "combat" = 4)
	build_path = /obj/item/spacepod_equipment/weaponry/burst_laser
	category = list("Pod_Weaponry")
	materials = list(MAT_METAL = 17500,MAT_PLASMA=3000)
	locked = 1

//////////////////////////////////////////
//////SPACEPOD MISC. ITEMS////////////////
//////////////////////////////////////////

/datum/design/paintkit
	construction_time = 100
	name = "Spacepod Paintkit Bucket"
	desc = "A bucket full with paint for your spacepod."
	id = "spacepodpaintkit"
	req_tech = list("materials" = 1, "combat" = 1, "engineering" = 1)
	build_type = PODFAB
	materials = list(MAT_METAL=5000)
	build_path = /obj/item/pod_paint_bucket
	category = list("Pod_Parts")

/datum/design/reinforced_plates_spacepod
	construction_time = 100
	name = "Spacepod Reinforced Engine"
	desc = "A bunch of plates that can be install near the engine to make it more robust but slower."
	id = "pod_plates_spacepod"
	req_tech = list("materials" = 5, "combat" = 4, "engineering" = 4)
	build_type = PODFAB
	materials = list(MAT_METAL=5000, MAT_SILVER = 2000)
	build_path = /obj/item/fluff/plates_spacepod
	category = list("Pod_Parts")

/datum/design/modified_engine
	construction_time = 100
	name = "Spacepod Modified Engine"
	desc = "A bunch of diagrams on how to make it faster but more easy to break."
	id = "pod_enginelight_spacepod"
	req_tech = list("materials" = 5, "combat" = 4, "engineering" = 4)
	build_type = PODFAB
	materials = list(MAT_METAL=5000, MAT_SILVER = 2000, ,MAT_BLUESPACE = 1000)
	build_path = /obj/item/fluff/plates_spacepod/velocity
	category = list("Pod_Parts")

/datum/design/basic_engine
	construction_time = 100
	name = "Spacepod Standard Engine"
	desc = "A bunch of diagrams on how to revert any changes to your engine."
	id = "pod_standard_spacepod"
	req_tech = list("materials" = 5, "combat" = 4, "engineering" = 4)
	build_type = PODFAB
	materials = list(MAT_METAL=5000)
	build_path = /obj/item/fluff/plates_spacepod/basic_engine
	category = list("Pod_Parts")

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
