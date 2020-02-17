/datum/design/mechmedbeam
	name = "Exosuit Medical Equipment (Beamgun)"
	desc = "Equipment for medical exosuits. Generates a focused beam of medical nanites."
	id = "mechmedbeamgun"
	build_type = MECHFAB
	req_tech = list("magnets" = 6,"biotech" = 7, "materials" = 7, "engineering" = 8)
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam
	materials = list(MAT_METAL=10000, MAT_GLASS = 4000, MAT_PLASMA = 5000, MAT_GOLD = 10000, MAT_DIAMOND = 5000)
	construction_time = 300
	category = list("Exosuit Equipment")

/datum/design/protomechmedbeam
	name = "Exosuit Medical Equipment (Prototype Beamgun)"
	desc = "Equipment for medical exosuits. Generates a focused beam of medical nanites. This prototype consumes excessive energy."
	id = "protomechmedbeamgun"
	build_type = MECHFAB
	req_tech = list("magnets" = 6,"biotech" = 7, "materials" = 7, "engineering" = 7)
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/protomechmedbeam
	materials = list(MAT_METAL=15000, MAT_GLASS = 8000, MAT_PLASMA = 4000, MAT_GOLD = 8000, MAT_DIAMOND = 2500)
	construction_time = 250
	category = list("Exosuit Equipment")

/datum/design/mech_syringe_gun/large
	name = "Exosuit Medical Equipment (Large Syringe Gun)"
	id = "mech_large_syringe_gun"
	build_type = MECHFAB
	req_tech = list("magnets" = 5,"biotech" = 5, "combat" = 4, "materials" = 5, "engineering" = 4)
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/large
	materials = list(MAT_METAL=4500,MAT_GLASS=3000,MAT_TITANIUM=3000)
	construction_time = 250
	category = list("Exosuit Equipment")

/datum/design/boris_ai_controller
	name = "B.O.R.I.S. AI-Cyborg Remote Control Module"
	id = "borg_ai_control"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/ai
	materials = list(MAT_METAL = 500, MAT_GLASS = 1500, MAT_GOLD = 1500)
	req_tech = list("programming" = 5, "magnets" = 4, "engineering" = 4)
	construction_time = 50
	category = list("Misc")

/datum/design/borg_upgrade_crewpinpointer
	name = "Cyborg Upgrade (Crew pinpointer)"
	id = "borg_upgrade_crewpinpointer"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/crewpinpointer
	req_tech = list("engineering" = 3, "biotech" = 6, "magnets" = 5)
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 500)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")
