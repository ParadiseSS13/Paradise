/datum/design/protomechmedbeam
	name = "Exosuit Medical Equipment (prototype beamgun)"
	desc = "Equipment for medical exosuits. Generates a focused beam of medical nanites. This prototype consumes excessive energy."
	id = "protomechmedbeamgun"
	build_type = MECHFAB
	req_tech = list("magnets" = 6,"biotech" = 7, "materials" = 7, "engineering" = 7)
	build_path = /obj/item/mecha_parts/mecha_equipment/medical/protomechmedbeam
	materials = list(MAT_METAL=15000, MAT_GLASS = 8000, MAT_PLASMA = 4000, MAT_GOLD = 8000, MAT_DIAMOND = 2500)
	construction_time = 250
	category = list("Exosuit Equipment")


