////////////////////////////////////////
/////////// Mecha Designs //////////////
////////////////////////////////////////
//Cyborg
/datum/design/borg_suit
	name = "Cyborg Endoskeleton"
	id = "borg_suit"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_suit
	materials = list(MAT_METAL=15000)
	construction_time = 500
	category = list("Cyborg")

/datum/design/borg_chest
	name = "Cyborg Torso"
	id = "borg_chest"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/chest
	materials = list(MAT_METAL=40000)
	construction_time = 350
	category = list("Cyborg")

/datum/design/borg_head
	name = "Cyborg Head"
	id = "borg_head"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/head
	materials = list(MAT_METAL=5000)
	construction_time = 350
	category = list("Cyborg")

/datum/design/borg_l_arm
	name = "Cyborg Left Arm"
	id = "borg_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_arm
	materials = list(MAT_METAL=10000)
	construction_time = 200
	category = list("Cyborg")

/datum/design/borg_r_arm
	name = "Cyborg Right Arm"
	id = "borg_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_arm
	materials = list(MAT_METAL=10000)
	construction_time = 200
	category = list("Cyborg")

/datum/design/borg_l_leg
	name = "Cyborg Left Leg"
	id = "borg_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/l_leg
	materials = list(MAT_METAL=10000)
	construction_time = 200
	category = list("Cyborg")

/datum/design/borg_r_leg
	name = "Cyborg Right Leg"
	id = "borg_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/r_leg
	materials = list(MAT_METAL=10000)
	construction_time = 200
	category = list("Cyborg")

//Robot repair
/datum/design/borg_binary_communication
	name = "Cyborg Binary Communication Device"
	id = "borg_binary_communication"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/binary_communication_device
	materials = list(MAT_METAL=2500, MAT_GLASS=1000)
	construction_time = 200
	category = list("Cyborg Repair")

/datum/design/borg_radio
	name = "Cyborg Radio"
	id = "borg_radio"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/radio
	materials = list(MAT_METAL=2500, MAT_GLASS=1000)
	construction_time = 200
	category = list("Cyborg Repair")

/datum/design/borg_actuator
	name = "Cyborg Actuator"
	id = "borg_actuator"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/actuator
	materials = list(MAT_METAL=3500)
	construction_time = 200
	category = list("Cyborg Repair")

/datum/design/borg_diagnosis_unit
	name = "Cyborg Diagnosis Unit"
	id = "borg_diagnosis_unit"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/diagnosis_unit
	materials = list(MAT_METAL=3500)
	construction_time = 200
	category = list("Cyborg Repair")

/datum/design/borg_camera
	name = "Cyborg Camera"
	id = "borg_camera"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/camera
	materials = list(MAT_METAL=2500, MAT_GLASS=1000)
	construction_time = 200
	category = list("Cyborg Repair")

/datum/design/borg_armor
	name = "Cyborg Armor"
	id = "borg_armor"
	build_type = MECHFAB
	build_path = /obj/item/robot_parts/robot_component/armour
	materials = list(MAT_METAL=5000)
	construction_time = 200
	category = list("Cyborg Repair")

//Ripley
/datum/design/ripley_chassis
	name = "Exosuit Chassis (APLU \"Ripley\")"
	id = "ripley_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/ripley
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("Ripley")

//Firefighter subtype
/datum/design/firefighter_chassis
	name = "Exosuit Chassis (APLU \"Firefighter\")"
	id = "firefighter_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/firefighter
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("Firefighter")

/datum/design/ripley_torso
	name = "Exosuit Torso (APLU \"Ripley\")"
	id = "ripley_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_torso
	materials = list(MAT_METAL=20000, MAT_GLASS=7500)
	construction_time = 200
	category = list("Ripley","Firefighter")

/datum/design/ripley_left_arm
	name = "Exosuit Left Arm (APLU \"Ripley\")"
	id = "ripley_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_arm
	materials = list(MAT_METAL=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

/datum/design/ripley_right_arm
	name = "Exosuit Right Arm (APLU \"Ripley\")"
	id = "ripley_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_arm
	materials = list(MAT_METAL=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

/datum/design/ripley_left_leg
	name = "Exosuit Left Leg (APLU \"Ripley\")"
	id = "ripley_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_leg
	materials = list(MAT_METAL=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

/datum/design/ripley_right_leg
	name = "Exosuit Right Leg (APLU \"Ripley\")"
	id = "ripley_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_leg
	materials = list(MAT_METAL=15000)
	construction_time = 150
	category = list("Ripley","Firefighter")

//Odysseus
/datum/design/odysseus_chassis
	name = "Exosuit Chassis (\"Odysseus\")"
	id = "odysseus_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/odysseus
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("Odysseus")

/datum/design/odysseus_torso
	name = "Exosuit Torso (\"Odysseus\")"
	id = "odysseus_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_torso
	materials = list(MAT_METAL=12000)
	construction_time = 180
	category = list("Odysseus")

/datum/design/odysseus_head
	name = "Exosuit Head (\"Odysseus\")"
	id = "odysseus_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_head
	materials = list(MAT_METAL=6000,MAT_GLASS=10000)
	construction_time = 100
	category = list("Odysseus")

/datum/design/odysseus_left_arm
	name = "Exosuit Left Arm (\"Odysseus\")"
	id = "odysseus_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_arm
	materials = list(MAT_METAL=6000)
	construction_time = 120
	category = list("Odysseus")

/datum/design/odysseus_right_arm
	name = "Exosuit Right Arm (\"Odysseus\")"
	id = "odysseus_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_arm
	materials = list(MAT_METAL=6000)
	construction_time = 120
	category = list("Odysseus")

/datum/design/odysseus_left_leg
	name = "Exosuit Left Leg (\"Odysseus\")"
	id = "odysseus_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_leg
	materials = list(MAT_METAL=7000)
	construction_time = 130
	category = list("Odysseus")

/datum/design/odysseus_right_leg
	name = "Exosuit Right Leg (\"Odysseus\")"
	id = "odysseus_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_leg
	materials = list(MAT_METAL=7000)
	construction_time = 130
	category = list("Odysseus")

//Gygax
/datum/design/gygax_chassis
	name = "Exosuit Chassis (\"Gygax\")"
	id = "gygax_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/gygax
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("Gygax")

/datum/design/gygax_torso
	name = "Exosuit Torso (\"Gygax\")"
	id = "gygax_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_torso
	materials = list(MAT_METAL=20000,MAT_GLASS=10000,MAT_DIAMOND=2000)
	construction_time = 300
	category = list("Gygax")

/datum/design/gygax_head
	name = "Exosuit Head (\"Gygax\")"
	id = "gygax_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_head
	materials = list(MAT_METAL=10000,MAT_GLASS=5000, MAT_DIAMOND=2000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_left_arm
	name = "Exosuit Left Arm (\"Gygax\")"
	id = "gygax_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_right_arm
	name = "Exosuit Right Arm (\"Gygax\")"
	id = "gygax_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_arm
	materials = list(MAT_METAL=15000, MAT_DIAMOND=1000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_left_leg
	name = "Exosuit Left Leg (\"Gygax\")"
	id = "gygax_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_right_leg
	name = "Exosuit Right Leg (\"Gygax\")"
	id = "gygax_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_leg
	materials = list(MAT_METAL=15000, MAT_DIAMOND=2000)
	construction_time = 200
	category = list("Gygax")

/datum/design/gygax_armor
	name = "Exosuit Armor (\"Gygax\")"
	id = "gygax_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_armour
	materials = list(MAT_METAL=15000,MAT_DIAMOND=10000,MAT_TITANIUM=10000)
	construction_time = 600
	category = list("Gygax")

//Durand
/datum/design/durand_chassis
	name = "Exosuit Chassis (\"Durand\")"
	id = "durand_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/durand
	materials = list(MAT_METAL=25000)
	construction_time = 100
	category = list("Durand")

/datum/design/durand_torso
	name = "Exosuit Torso (\"Durand\")"
	id = "durand_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_torso
	materials = list(MAT_METAL=25000,MAT_GLASS=10000,MAT_SILVER=10000)
	construction_time = 300
	category = list("Durand")

/datum/design/durand_head
	name = "Exosuit Head (\"Durand\")"
	id = "durand_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_head
	materials = list(MAT_METAL=10000,MAT_GLASS=15000,MAT_SILVER=2000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_left_arm
	name = "Exosuit Left Arm (\"Durand\")"
	id = "durand_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_arm
	materials = list(MAT_METAL=10000,MAT_SILVER=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_right_arm
	name = "Exosuit Right Arm (\"Durand\")"
	id = "durand_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_arm
	materials = list(MAT_METAL=10000,MAT_SILVER=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_left_leg
	name = "Exosuit Left Leg (\"Durand\")"
	id = "durand_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_leg
	materials = list(MAT_METAL=15000,MAT_SILVER=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_right_leg
	name = "Exosuit Right Leg (\"Durand\")"
	id = "durand_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_leg
	materials = list(MAT_METAL=15000,MAT_SILVER=4000)
	construction_time = 200
	category = list("Durand")

/datum/design/durand_armor
	name = "Exosuit Armor (\"Durand\")"
	id = "durand_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_armor
	materials = list(MAT_METAL=30000,MAT_URANIUM=25000,MAT_TITANIUM=20000)
	construction_time = 600
	category = list("Durand")

//H.O.N.K
/datum/design/honk_chassis
	name = "Exosuit Chassis (\"H.O.N.K\")"
	id = "honk_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/honker
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("H.O.N.K")

/datum/design/honk_torso
	name = "Exosuit Torso (\"H.O.N.K\")"
	id = "honk_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_torso
	materials = list(MAT_METAL=20000,MAT_GLASS=10000,MAT_BANANIUM=10000)
	construction_time = 300
	category = list("H.O.N.K")

/datum/design/honk_head
	name = "Exosuit Head (\"H.O.N.K\")"
	id = "honk_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_head
	materials = list(MAT_METAL=10000,MAT_GLASS=5000,MAT_BANANIUM=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_left_arm
	name = "Exosuit Left Arm (\"H.O.N.K\")"
	id = "honk_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_left_arm
	materials = list(MAT_METAL=15000,MAT_BANANIUM=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_right_arm
	name = "Exosuit Right Arm (\"H.O.N.K\")"
	id = "honk_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_arm
	materials = list(MAT_METAL=15000,MAT_BANANIUM=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_left_leg
	name = "Exosuit Left Leg (\"H.O.N.K\")"
	id = "honk_left_leg"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/part/honker_left_leg
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 200
	category = list("H.O.N.K")

/datum/design/honk_right_leg
	name = "Exosuit Right Leg (\"H.O.N.K\")"
	id = "honk_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_leg
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 200
	category = list("H.O.N.K")

//Reticence
/datum/design/reticence_chassis
	name = "Exosuit Chassis (\"Reticence\")"
	id = "reticence_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/reticence
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("Reticence")

/datum/design/reticence_torso
	name = "Exosuit Torso (\"Reticence\")"
	id = "reticence_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_torso
	materials = list(MAT_METAL=20000,MAT_GLASS=10000,MAT_TRANQUILLITE=10000)
	construction_time = 300
	category = list("Reticence")

/datum/design/reticence_head
	name = "Exosuit Head (\"Reticence\")"
	id = "reticence_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_head
	materials = list(MAT_METAL=10000,MAT_GLASS=5000,MAT_TRANQUILLITE=5000)
	construction_time = 200
	category = list("Reticence")

/datum/design/reticence_left_arm
	name = "Exosuit Left Arm (\"Reticence\")"
	id = "reticence_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_left_arm
	materials = list(MAT_METAL=15000,MAT_TRANQUILLITE=5000)
	construction_time = 200
	category = list("Reticence")

/datum/design/reticence_right_arm
	name = "Exosuit Right Arm (\"Reticence\")"
	id = "reticence_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_right_arm
	materials = list(MAT_METAL=15000,MAT_TRANQUILLITE=5000)
	construction_time = 200
	category = list("Reticence")

/datum/design/reticence_left_leg
	name = "Exosuit Left Leg (\"Reticence\")"
	id = "reticence_left_leg"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/part/reticence_left_leg
	materials = list(MAT_METAL=20000,MAT_TRANQUILLITE=5000)
	construction_time = 200
	category = list("Reticence")

/datum/design/reticence_right_leg
	name = "Exosuit Right Leg (\"Reticence\")"
	id = "reticence_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/reticence_right_leg
	materials = list(MAT_METAL=20000,MAT_TRANQUILLITE=5000)
	construction_time = 200
	category = list("Reticence")

//Phazon
/datum/design/phazon_chassis
	name = "Exosuit Chassis (\"Phazon\")"
	id = "phazon_chassis"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/phazon
	materials = list(MAT_METAL=20000)
	construction_time = 100
	category = list("Phazon")

/datum/design/phazon_torso
	name = "Exosuit Torso (\"Phazon\")"
	id = "phazon_torso"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_torso
	materials = list(MAT_METAL=35000,MAT_GLASS=10000,MAT_PLASMA=20000)
	construction_time = 300
	category = list("Phazon")

/datum/design/phazon_head
	name = "Exosuit Head (\"Phazon\")"
	id = "phazon_head"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_head
	materials = list(MAT_METAL=15000,MAT_GLASS=5000,MAT_PLASMA=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_left_arm
	name = "Exosuit Left Arm (\"Phazon\")"
	id = "phazon_left_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_arm
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_right_arm
	name = "Exosuit Right Arm (\"Phazon\")"
	id = "phazon_right_arm"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_arm
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_left_leg
	name = "Exosuit Left Leg (\"Phazon\")"
	id = "phazon_left_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_leg
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_right_leg
	name = "Exosuit Right Leg (\"Phazon\")"
	id = "phazon_right_leg"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_leg
	materials = list(MAT_METAL=20000,MAT_PLASMA=10000)
	construction_time = 200
	category = list("Phazon")

/datum/design/phazon_armor
	name = "Exosuit Armor (\"Phazon\")"
	id = "phazon_armor"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_armor
	materials = list(MAT_METAL=25000,MAT_PLASMA=20000,MAT_TITANIUM=20000)
	construction_time = 300
	category = list("Phazon")

//Exosuit Equipment
/datum/design/mech_cable_layer
	name = "Exosuit Engineering Equipment (Cable Layer)"
	id = "mech_cable_layer"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/cable_layer
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_drill
	name = "Exosuit Engineering Equipment (Drill)"
	id = "mech_drill"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/drill
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_extinguisher
	name = "Exosuit Engineering Equipment (Extinguisher)"
	id = "mech_extinguisher"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/extinguisher
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_hydraulic_clamp
	name = "Exosuit Engineering Equipment (Hydraulic Clamp)"
	id = "mech_hydraulic_clamp"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_sleeper
	name = "Exosuit Medical Equipment (Mounted Sleeper)"
	id = "mech_sleeper"
	build_type = MECHFAB
	req_tech = list("biotech" = 3, "engineering" = 3, "plasmatech" = 2)
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/sleeper
	materials = list(MAT_METAL=5000,MAT_GLASS=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_syringe_gun
	name = "Exosuit Medical Equipment (Syringe Gun)"
	id = "mech_syringe_gun"
	build_type = MECHFAB
	req_tech = list("magnets" = 4,"biotech" = 4, "combat" = 3, "materials" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	materials = list(MAT_METAL=3000,MAT_GLASS=2000)
	construction_time = 200
	category = list("Exosuit Equipment")

/datum/design/medical_jaw
	name = "Exosuit Medical Equipment (Rescue Jaw)"
	id = "mech_medical_jaw"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw
	req_tech = list("materials" = 4, "engineering" = 6, "magnets" = 6)	//now same as jaws of life
	materials = list(MAT_METAL=5000,MAT_SILVER=2000,MAT_TITANIUM=1500)
	construction_time = 200
	category = list("Exosuit Equipment")

/datum/design/mech_generator
	name = "Exosuit Equipment (Plasma Generator)"
	id = "mech_generator"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/generator
	materials = list(MAT_METAL=10000,MAT_GLASS=1000,MAT_SILVER=2000,MAT_PLASMA=5000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_taser
	name = "Exosuit Weapon (PBT \"Pacifier\" Mounted Taser)"
	id = "mech_taser"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_lmg
	name = "Exosuit Weapon (\"Ultra AC 2\" LMG)"
	id = "mech_lmg"
	build_type = MECHFAB
	req_tech = list("combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_banana_mortar
	name = "H.O.N.K Banana Mortar"
	id = "mech_banana_mortar"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 300
	category = list("Exosuit Equipment")

/datum/design/mech_honker
	name = "HoNkER BlAsT 5000"
	id = "mech_honker"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/honker
	materials = list(MAT_METAL=20000,MAT_BANANIUM=10000)
	construction_time = 500
	category = list("Exosuit Equipment")

/datum/design/mech_mousetrap_mortar
	name = "H.O.N.K Mousetrap Mortar"
	id = "mech_mousetrap_mortar"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	materials = list(MAT_METAL=20000,MAT_BANANIUM=5000)
	construction_time = 300
	category = list("Exosuit Equipment")

/datum/design/mech_silentgun
	name = "S.H.H. \"Quietus\" Carbine"
	id = "mech_silentgun"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced
	materials = list(MAT_METAL=20000,MAT_TRANQUILLITE=10000)
	construction_time = 500
	category = list("Exosuit Equipment")

/datum/design/mech_mimercd
	name = "Exosuit Module (Mime RCD Module)"
	desc = "An exosuit-mounted Mime Rapid Construction Device."
	id = "mech_mrcd"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/mimercd
	materials = list(MAT_METAL=30000,MAT_TRANQUILLITE=10000)
	construction_time = 700
	category = list("Exosuit Equipment")

// Exosuit Modules
/datum/design/mech_diamond_drill
	name = "Exosuit Module (Diamond Mining Drill)"
	desc = "An upgraded version of the standard drill."
	id = "mech_diamond_drill"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill
	materials = list(MAT_METAL=10000,MAT_DIAMOND=6500)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_mining_scanner
	name = "Exosuit Engineering Equipement (Mining Scanner)"
	id = "mech_mscanner"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/mining_scanner
	materials = list(MAT_METAL=5000,MAT_GLASS=2500)
	construction_time = 50
	category = list("Exosuit Equipment")

/datum/design/mech_generator_nuclear
	name = "Exosuit Module (ExoNuclear Reactor)"
	desc = "Compact nuclear reactor module."
	id = "mech_generator_nuclear"
	build_type = MECHFAB
	req_tech = list("powerstorage"= 5, "engineering" = 4, "materials" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/generator/nuclear
	materials = list(MAT_METAL=10000,MAT_GLASS=1000,MAT_SILVER=500)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_gravcatapult
	name = "Exosuit Module (Gravitational Catapult Module)"
	desc = "An exosuit mounted Gravitational Catapult."
	id = "mech_gravcatapult"
	build_type = MECHFAB
	req_tech = list("bluespace" = 4, "magnets" = 3, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/gravcatapult
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_wormhole_gen
	name = "Exosuit Module (Localized Wormhole Generator)"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	id = "mech_wormhole_gen"
	build_type = MECHFAB
	req_tech = list("bluespace" = 4, "magnets" = 4, "plasmatech" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/wormhole_generator
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_rcd
	name = "Exosuit Module (RCD Module)"
	desc = "An exosuit-mounted Rapid Construction Device."
	id = "mech_rcd"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "bluespace" = 3, "magnets" = 4, "powerstorage"=4, "engineering" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/rcd
	materials = list(MAT_METAL=30000,MAT_GOLD=20000,MAT_PLASMA=25000,MAT_SILVER=20000)
	construction_time = 1200
	category = list("Exosuit Equipment")

/datum/design/mech_ccw_armor
	name = "Exosuit Module (Reactive Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_ccw_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	materials = list(MAT_METAL=20000,MAT_SILVER=5000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_proj_armor
	name = "Exosuit Module (Reflective Armor Booster Module)"
	desc = "Exosuit-mounted armor booster."
	id = "mech_proj_armor"
	build_type = MECHFAB
	req_tech = list("materials" = 5, "combat" = 5, "engineering"=3)
	build_path = /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	materials = list(MAT_METAL=20000,MAT_GOLD=5000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_repair_droid
	name = "Exosuit Module (Repair Droid Module)"
	desc = "Automated Repair Droid. BEEP BOOP"
	id = "mech_repair_droid"
	build_type = MECHFAB
	req_tech = list("magnets" = 3, "programming" = 3, "engineering" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/repair_droid
	materials = list(MAT_METAL=10000,MAT_GLASS=5000,MAT_GOLD=1000,MAT_SILVER=2000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/clusterbang_launcher
	name = "Exosuit Module (SOB-3 Clusterbang Launcher)"
	desc = "A weapon that violates the Geneva Convention at 3 rounds per minute"
	id = "clusterbang_launcher"
	build_type = MECHFAB
	req_tech = list("combat"= 5, "materials" = 5, "syndicate" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang
	materials = list(MAT_METAL=20000,MAT_GOLD=10000,MAT_URANIUM=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_bola
	name = "Exosuit Weapon Design (PCMK-6 Bola Launcher)"
	desc = "Allows for the construction of PCMK-6 Bola Launcher."
	id = "mech_bola"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_teleporter
	name = "Exosuit Module (Teleporter Module)"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	id = "mech_teleporter"
	build_type = MECHFAB
	req_tech = list("bluespace" = 8, "magnets" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/teleporter
	materials = list(MAT_METAL=10000,MAT_DIAMOND=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_energy_relay
	name = "Exosuit Module (Tesla Energy Relay)"
	desc = "Tesla Energy Relay"
	id = "mech_energy_relay"
	build_type = MECHFAB
	req_tech = list("magnets" = 4, "powerstorage" = 5, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	materials = list(MAT_METAL=10000,MAT_GLASS=2000,MAT_GOLD=2000,MAT_SILVER=3000)
	construction_time = 100
	category = list("Exosuit Equipment")

// Exosuit Weapons
/datum/design/mech_laser_heavy
	name = "Exosuit Weapon (CH-LC \"Solaris\" Laser Cannon)"
	desc = "Allows for the construction of CH-LC Laser Cannon."
	id = "mech_laser_heavy"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "magnets" = 4, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_laser
	name = "Exosuit Weapon (CH-PL \"Firedart\" Laser)"
	desc = "Allows for the construction of CH-PS Laser."
	id = "mech_laser"
	build_type = MECHFAB
	req_tech = list("combat" = 3, "magnets" = 3, "engineering" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_disabler
	name = "Exosuit Weapon (CH-PD Disabler)"
	desc = "Allows for the construction of CH-PD Disabler."
	id = "mech_disabler"
	build_type = MECHFAB
	req_tech = list("combat" = 3)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_carbine
	name = "Exosuit Weapon (FNX-99 \"Hades\" Carbine)"
	desc = "Allows for the construction of FNX-99 \"Hades\" Carbine."
	id = "mech_carbine"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "materials" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_scattershot
	name = "Exosuit Weapon (LBX AC 10 \"Scattershot\")"
	desc = "Allows for the construction of LBX AC 10."
	id = "mech_scattershot"
	build_type = MECHFAB
	req_tech = list("combat" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_ion
	name = "Exosuit Weapon (MKIV Ion Heavy Cannon)"
	desc = "Allows for the construction of MKIV Ion Heavy Cannon."
	id = "mech_ion"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "magnets" = 5, "materials" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	materials = list(MAT_METAL=20000,MAT_SILVER=6000,MAT_URANIUM=2000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_grenade_launcher
	name = "Exosuit Weapon (SGL-6 Grenade Launcher)"
	desc = "Allows for the construction of SGL-6 Grenade Launcher."
	id = "mech_grenade_launcher"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	materials = list(MAT_METAL=22000,MAT_GOLD=6000,MAT_SILVER=8000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_missile_rack
	name = "Exosuit Weapon (SRM-8 Missile Rack)"
	desc = "Allows for the construction of SRM-8 Missile Rack."
	id = "mech_missile_rack"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "materials" = 5, "engineering" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	materials = list(MAT_METAL=22000,MAT_GOLD=6000,MAT_SILVER=8000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_plasma_cutter
	name = "Exosuit Module Design (217-D Heavy Plasma Cutter)"
	desc = "A device that shoots resonant plasma bursts at extreme velocity. The blasts are capable of crushing rock and demolishing solid obstacles."
	id = "mech_plasma_cutter"
	build_type = MECHFAB
	req_tech = list("engineering" = 4, "materials" = 5, "plasmatech" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2000, MAT_PLASMA = 6000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_tesla
	name = "Exosuit Weapon (P-X Tesla Cannon)"
	desc = "Allows for the construction of P-X Tesla Cannon."
	id = "mech_tesla"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "magnets" = 5, "materials" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	materials = list(MAT_METAL=20000,MAT_SILVER=8000)
	construction_time = 100
	category = list("Exosuit Equipment")

/datum/design/mech_immolator
	name = "Exosuit Weapon (ZFI Immolation Beam Gun)"
	desc = "Allows for the construction of ZFI Immolation Beam Gun."
	id = "mech_immolator"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "magnets" = 5, "materials" = 5)
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator
	materials = list(MAT_METAL = 10000, MAT_SILVER = 8000, MAT_PLASMA = 8000)
	construction_time = 100
	category = list("Exosuit Equipment")

//Cyborg Upgrade Modules

/datum/design/borg_upgrade_reset
	name = "Cyborg Upgrade Module (Reset)"
	id = "borg_upgrade_reset"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/reset
	materials = list(MAT_METAL=10000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_rename
	name = "Cyborg Upgrade Module (Rename)"
	id = "borg_upgrade_rename"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rename
	materials = list(MAT_METAL=35000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_restart
	name = "Cyborg Upgrade Module (Restart)"
	id = "borg_upgrade_restart"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/restart
	materials = list(MAT_METAL=60000 , MAT_GLASS=5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_vtec
	name = "Cyborg Upgrade Module (VTEC)"
	id = "borg_upgrade_vtec"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/vtec
	req_tech = list("engineering" = 4, "materials" = 5, "programming" = 4)
	materials = list(MAT_METAL=80000 , MAT_GLASS=6000 , MAT_URANIUM= 5000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_thrusters
	name = "Cyborg Upgrade (Ion Thrusters)"
	id = "borg_upgrade_thrusters"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/thrusters
	req_tech = list("engineering" = 4, "powerstorage" = 4)
	materials = list(MAT_METAL=10000, MAT_PLASMA=5000, MAT_URANIUM = 6000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_disablercooler
	name = "Cyborg Upgrade Module (Rapid Disabler Cooling)"
	id = "borg_upgrade_disablercooler"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/disablercooler
	req_tech = list("combat" = 5, "powerstorage" = 4, "engineering" = 4)
	materials = list(MAT_METAL=80000 , MAT_GLASS=6000 , MAT_GOLD= 2000, MAT_DIAMOND = 500)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_diamonddrill
	name = "Cyborg Upgrade (Diamond Drill)"
	id = "borg_upgrade_diamonddrill"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/ddrill
	req_tech = list("engineering" = 5, "materials" = 6)
	materials = list(MAT_METAL=10000, MAT_DIAMOND=2000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_holding
	name = "Cyborg Upgrade (Ore Satchel of Holding)"
	id = "borg_upgrade_holding"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/soh
	req_tech = list("engineering" = 4, "materials" = 4, "bluespace" = 4)
	materials = list(MAT_METAL = 10000, MAT_GOLD = 250, MAT_URANIUM = 500)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_syndicate_module
	name = "Cyborg Upgrade (Illegal Modules)"
	id = "borg_syndicate_module"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "syndicate" = 2)
	build_path = /obj/item/borg/upgrade/syndicate
	materials = list(MAT_METAL=10000,MAT_GLASS=15000,MAT_DIAMOND = 10000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/datum/design/borg_upgrade_selfrepair
	name = "Cyborg Upgrade (Self-repair)"
	id = "borg_upgrade_selfrepair"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/selfrepair
	req_tech = list("materials" = 4, "engineering" = 4)
	materials = list(MAT_METAL=15000, MAT_GLASS=15000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

//Misc
/datum/design/mecha_tracking
	name = "Exosuit Tracking Beacon"
	id = "mecha_tracking"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/mecha_tracking
	materials = list(MAT_METAL=500)
	construction_time = 50
	category = list("Misc")

/datum/design/mecha_tracking_ai_control
	name = "AI Control Beacon"
	id = "mecha_tracking_ai_control"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_tracking/ai_control
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 200)
	req_tech = list("programming" = 3, "magnets" = 2, "engineering" = 2)
	construction_time = 50
	category = list("Misc")

/datum/design/ipc_head
	name = "IPC Head"
	id = "ipc_head"
	build_type = MECHFAB
	build_path = /obj/item/organ/external/head/ipc
	materials = list(MAT_METAL=15000, MAT_GLASS=5000)
	construction_time = 350
	category = list("Misc")

/datum/design/integrated_robotic_chassis
	name = "Integrated Robotic Chassis"
	id = "integrated_robotic_chassis"
	build_type = MECHFAB
	build_path = /mob/living/carbon/human/machine/created
	materials = list(MAT_METAL = 40000, MAT_TITANIUM = 7000) //for something made from lego, they sure need a lot of metal
	construction_time = 400
	category = list("Misc")

/datum/design/ipc_cell
	name = "IPC Microbattery"
	id = "ipc_cell"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/cell
	materials = list(MAT_METAL=2000, MAT_GLASS=750)
	construction_time = 200
	category = list("Misc")

/datum/design/ipc_charger
	name = "IPC Charger"
	id = "ipc_cahrger"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/cyberimp/arm/power_cord
	materials = list(MAT_METAL=2000, MAT_GLASS=1000)
	construction_time = 200
	category = list("Misc")

/datum/design/ipc_optics
	name = "IPC Optical Sensor"
	id = "ipc_optics"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/eyes/optical_sensor
	materials = list(MAT_METAL=1000, MAT_GLASS=2500)
	construction_time = 200
	category = list("Misc")

/datum/design/ipc_microphone
	name = "IPC Microphone"
	id = "ipc_microphone"
	build_type = MECHFAB
	build_path = /obj/item/organ/internal/ears/microphone
	materials = list(MAT_METAL = 1000, MAT_GLASS = 2500)
	construction_time = 200
	category = list("Misc")

/datum/design/synthetic_flash
	name = "Synthetic Flash"
	desc = "A synthetic flash used mostly in borg construction."
	id = "sflash"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 750, MAT_GLASS = 750)
	construction_time = 100
	build_path = /obj/item/flash/synthetic
	category = list("Misc")

/datum/design/voice_standard
	name = "Voice Modkit : Standard"
	desc = "A modification kit that updates a mech's onboard voice to Standard."
	id = "voice_standard"
	build_type = MECHFAB
	materials = list(MAT_METAL = 500)
	construction_time = 50
	build_path = /obj/item/mecha_modkit/voice
	category = list("Misc")

/datum/design/voice_nanotrasen
	name = "Voice Modkit : Nanotrasen"
	desc = "A modification kit that updates a mech's onboard voice to Nanotrasen."
	id = "voice_nanotrasen"
	build_type = MECHFAB
	materials = list(MAT_METAL = 500)
	construction_time = 50
	build_path = /obj/item/mecha_modkit/voice/nanotrasen
	category = list("Misc")

/datum/design/voice_silent
	name = "Voice Modkit : Silent"
	desc = "A modification kit that silences a mech's onboard voice."
	id = "voice_silent"
	build_type = MECHFAB
	materials = list(MAT_METAL = 500)
	construction_time = 50
	build_path = /obj/item/mecha_modkit/voice/silent
	category = list("Misc")

/datum/design/voice_honk
	name = "Voice Modkit : Honk"
	desc = "A modification kit that updates a mech's onboard voice to Honk. This is a terrible idea."
	id = "voice_honk"
	build_type = MECHFAB
	materials = list(MAT_METAL = 400, MAT_BANANIUM = 100)
	construction_time = 50
	build_path = /obj/item/mecha_modkit/voice/honk
	category = list("Misc")

/datum/design/voice_syndicate
	name = "Voice Modkit : Syndicate"
	desc = "A modification kit that updates a mech's onboard voice to Syndicate."
	id = "voice_syndicate"
	build_type = MECHFAB
	materials = list(MAT_METAL = 400, MAT_TITANIUM = 100)
	req_tech = list("syndicate" = 2)
	construction_time = 50
	build_path = /obj/item/mecha_modkit/voice/syndicate
	category = list("Misc")
