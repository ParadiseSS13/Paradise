/datum/design/spacepod_main
	construction_time = 100
	name = "Circuit Design (Space Pod Mainboard)"
	desc = "Allows for the construction of a Space Pod mainboard."
	id = "spacepod_main"
	req_tech = list("materials" = 1) //All parts required to build a basic pod have materials 1, so the mechanic can do his damn job.
	build_type = PODFAB
	materials = list(MAT_METAL=5000)
	build_path = /obj/item/weapon/circuitboard/mecha/pod
	category = list("Pod_Parts")

//////////////////////////////////////////////////
/////////SPACEPOD PARTS///////////////////////////
//////////////////////////////////////////////////
/datum/design/podframe_fp
	construction_time = 200
	name = "Fore port pod frame"
	desc = "Allows for the construction of spacepod frames. This is the fore port component."
	id = "podframefp"
	build_type = PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/pod_frame/fore_port
	category = list("Pod_Frame")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)

/datum/design/podframe_ap
	construction_time = 200
	name = "Aft port pod frame"
	desc = "Allows for the construction of spacepod frames. This is the aft port component."
	id = "podframeap"
	build_type = PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/pod_frame/aft_port
	category = list("Pod_Frame")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)

/datum/design/podframe_fs
	construction_time = 200
	name = "Fore starboard pod frame"
	desc = "Allows for the construction of spacepod frames. This is the fore starboard component."
	id = "podframefs"
	build_type = PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/pod_frame/fore_starboard
	category = list("Pod_Frame")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)

/datum/design/podframe_as
	construction_time = 200
	name = "Aft starboard pod frame"
	desc = "Allows for the construction of spacepod frames. This is the aft starboard component."
	id = "podframeas"
	build_type = PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/pod_frame/aft_starboard
	category = list("Pod_Frame")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000)

//////////////////////////
////////POD CORE////////
//////////////////////////

/datum/design/pod_core
	construction_time = 700 //Pod core should take a bit to process, after all, it's a big complicated engine and stuff.
	name = "Spacepod Core"
	desc = "Allows for the construction of a spacepod core system, made up of the engine and life support systems."
	id = "podcore"
	build_type = MECHFAB | PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/core
	category = list("Pod_Parts")
	materials = list(MAT_METAL=5000,MAT_URANIUM=1000,MAT_PLASMA=5000)

//////////////////////////////////////////
////////SPACEPOD ARMOR////////////////////
//////////////////////////////////////////

/datum/design/pod_armor_civ
	construction_time = 400 //more time than frames, less than pod core
	name = "Pod Armor (civilian)"
	desc = "Allows for the construction of spacepod armor. This is the civilian version."
	id = "podarmor_civ"
	build_type = PODFAB
	req_tech = list("materials" = 1)
	build_path = /obj/item/pod_parts/armor
	category = list("Pod_Armor")
	materials = list(MAT_METAL=15000,MAT_GLASS=5000,MAT_PLASMA=10000)

//////////////////////////////////////////
//////SPACEPOD GUNS///////////////////////
//////////////////////////////////////////
/datum/design/pod_gun_taser
	construction_time = 200
	name = "Spacepod Equipment (Taser)"
	desc = "Allows for the construction of a spacepod mounted taser."
	id = "podgun_taser"
	build_type = PODFAB
	req_tech = list("materials" = 2, "combat" = 2)
	build_path = /obj/item/device/spacepod_equipment/weaponry/taser
	category = list("Pod_Weaponry")
	materials = list(MAT_METAL = 15000)
	locked = 1

/datum/design/pod_gun_btaser
	construction_time = 200
	name = "Spacepod Equipment (Burst Taser)"
	desc = "Allows for the construction of a spacepod mounted taser. This is the burst-fire model."
	id = "podgun_btaser"
	build_type = PODFAB
	req_tech = list("materials" = 3, "combat" = 3)
	build_path = /obj/item/device/spacepod_equipment/weaponry/burst_taser
	category = list("Pod_Weaponry")
	materials = list(MAT_METAL = 15000,MAT_PLASMA=2000)
	locked = 1

/datum/design/pod_gun_laser
	construction_time = 200
	name = "Spacepod Equipment (Laser)"
	desc = "Allows for the construction of a spacepod mounted laser."
	id = "podgun_laser"
	build_type = PODFAB
	req_tech = list("materials" = 3, "combat" = 3, "plasma" = 2)
	build_path = /obj/item/device/spacepod_equipment/weaponry/laser
	category = list("Pod_Weaponry")
	materials = list(MAT_METAL=10000,MAT_GLASS=5000,MAT_GOLD=1000,MAT_SILVER=2000)
	locked = 1
//////////////////////////////////////////
//////SPACEPOD MISC. ITEMS////////////////
//////////////////////////////////////////

/datum/design/pod_misc_tracker
	construction_time = 100
	name = "Spacepod Tracking Module"
	desc = "Allows for the construction of a Space Pod Tracking Module."
	id = "podmisc_tracker"
	req_tech = list("materials" = 2) //Materials 2: easy to get, no trackers with 0 science progress
	build_type = PODFAB
	materials = list(MAT_METAL=5000)
	build_path = /obj/item/device/spacepod_equipment/misc/tracker
	category = list("Pod_Parts")