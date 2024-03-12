/obj/machinery/mecha_part_fabricator/Initialize(mapload)
	. = ..()

	categories.Insert(categories.Find("Exosuit Equipment")+1,  "Exosuit Paintkits")

// Paintkits
/datum/design/paint_ripley_titan
	name = "Ripley, Firefighter \"Titan's Fist\""
	id = "p_titan"
	build_type = MECHFAB
	req_tech = list("programming" = 4, "materials" = 2)
	build_path = /obj/item/paintkit/ripley_titansfist
	materials = list(MAT_METAL=20000, MAT_PLASMA=2000, MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_ripley_earth
	name = "Ripley, Firefighter \"Strike the Earth!\""
	id = "p_earth"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "materials" = 2)
	build_path = /obj/item/paintkit/ripley_gurren
	materials = list(MAT_METAL=10000, MAT_PLASMA=2000, MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_ripley_red
	name = "Ripley, Firefighter \"Firestarter\""
	id = "p_red"
	build_type = MECHFAB
	req_tech = list("engineering" = 4, "materials" = 2)
	build_path = /obj/item/paintkit/ripley_red
	materials = list(MAT_METAL=10000, MAT_PLASMA=2000, MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_firefighter_hauler
	name = "Ripley, Firefighter \"Hauler\""
	id = "p_hauler"
	build_type = MECHFAB
	req_tech = list("biotech" = 4, "materials" = 2)
	build_path = /obj/item/paintkit/firefighter_Hauler
	materials = list(MAT_METAL=10000, MAT_PLASMA=2000, MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_firefighter_zairjah
	name = "Ripley, Firefighter \"Zairjah\""
	id = "p_zairjah"
	build_type = MECHFAB
	req_tech = list("engineering" = 4, "materials" = 2)
	build_path = /obj/item/paintkit/firefighter_zairjah
	materials = list(MAT_METAL=10000, MAT_PLASMA=2000, MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_firefighter_combat
	name = "Ripley, Firefighter \"Combat Ripley\""
	id = "p_combat"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "materials" = 2)
	build_path = /obj/item/paintkit/firefighter_combat
	materials = list(MAT_METAL=10000, MAT_PLASMA=2000, MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_firefighter_aluminizer
	name = "Ripley, Firefighter \"Aluminizer\""
	id = "p_aluminizer"
	build_type = MECHFAB
	req_tech = list("engineering" = 4, "materials" = 2)
	build_path = /obj/item/paintkit/firefighter_aluminizer
	materials = list(MAT_METAL=10000, MAT_PLASMA=2000, MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_firefighter_reaper
	name = "Ripley, Firefighter \"Reaper\""
	id = "p_reaper"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "toxins" = 5)
	build_path = /obj/item/paintkit/firefighter_Reaper
	materials = list(MAT_METAL=10000, MAT_PLASMA=2000, MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_odysseus_hermes
	name = "Odysseus \"Hermes\""
	id = "p_hermes"
	build_type = MECHFAB
	req_tech = list("engineering" = 5, "biotech" = 5)
	build_path = /obj/item/paintkit/odysseus_hermes
	materials = list(MAT_METAL=20000, MAT_GOLD=2000, MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_odysseus_reaper
	name = "Odysseus \"Reaper\""
	id = "p_odyreaper"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "biotech" = 5)
	build_path = /obj/item/paintkit/odysseus_death
	materials = list(MAT_METAL=20000, MAT_GOLD=2000, MAT_GLASS=2000)
	construction_time = 10 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_alt
	name = "Gygax \"Old\""
	id = "p_altgygax"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "engineering" = 5, "materials" = 5, "programming" = 4)
	build_path = /obj/item/paintkit/gygax_alt
	materials = list(MAT_METAL=30000, MAT_GLASS =3000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_pobeda
	name = "Gygax \"Pobeda\""
	id = "p_pobedagygax"
	build_type = MECHFAB
	req_tech = list("combat" = 5, "engineering" = 4, "materials" = 4, "programming" = 6)
	build_path = /obj/item/paintkit/gygax_pobeda
	materials = list(MAT_METAL=30000, MAT_DIAMOND=3000, MAT_URANIUM= 3000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_white
	name = "Gygax \"White\""
	id = "p_whitegygax"
	build_type = MECHFAB
	req_tech = list("biotech" = 4, "engineering" = 4, "materials" = 5, "programming" = 3)
	build_path = /obj/item/paintkit/gygax_white
	materials = list(MAT_METAL=30000, MAT_TITANIUM=3000, MAT_URANIUM= 3000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_mime
	name = "Gygax \"Recitence\""
	id = "p_gygax_mime"
	build_type = MECHFAB
	req_tech = list("biotech" = 4, "engineering" = 4, "materials" = 5, "programming" = 3)
	build_path = /obj/item/paintkit/gygax_mime
	materials = list(MAT_METAL=30000, MAT_TITANIUM=3000, MAT_TRANQUILLITE= 2000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_medgax
	name = "Gygax \"Medgax\""
	id = "p_medgax"
	build_type = MECHFAB
	req_tech = list("biotech" = 4, "engineering" = 4, "materials" = 5, "programming" = 3)
	build_path = /obj/item/paintkit/gygax_medgax
	materials = list(MAT_METAL=30000, MAT_TITANIUM=3000, MAT_URANIUM= 3000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_gygax_black
	name = "Gygax \"Syndicate\""
	id = "p_blackgygax"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "engineering" = 5, "syndicate" = 3)
	build_path = /obj/item/paintkit/gygax_syndie
	materials = list(MAT_METAL=30000, MAT_TRANQUILLITE=2000, MAT_DIAMOND=4000)
	construction_time = 20 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_durand_unathi
	name = "Durand \"Kharn MK. IV\""
	id = "p_unathi"
	build_type = MECHFAB
	req_tech = list("materials" = 6, "biotech" = 6)
	build_path = /obj/item/paintkit/durand_unathi
	materials = list(MAT_METAL=40000, MAT_TITANIUM=4000, MAT_URANIUM=4000)
	construction_time = 30 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_durand_shire
	name = "Durand \"Shire\""
	id = "p_shire"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "engineering" = 6, "materials" = 6, "programming" = 6)
	build_path = /obj/item/paintkit/durand_shire
	materials = list(MAT_METAL=40000, MAT_TRANQUILLITE=2000, MAT_TITANIUM=4000)
	construction_time = 30 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_durand_soviet
	name = "Durand \"Dollhouse\""
	id = "p_soviet"
	build_type = MECHFAB
	req_tech = list("combat" = 6, "engineering" = 6, "materials" = 6, "programming" = 6)
	build_path = /obj/item/paintkit/durand_soviet
	materials = list(MAT_METAL=40000, MAT_DIAMOND=4000, MAT_URANIUM=4000, MAT_TITANIUM=4000)
	construction_time = 30 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_phazon_imperion
	name = "Phazon \"Imperion\""
	id = "p_imperion"
	build_type = MECHFAB
	req_tech = list("bluespace" = 7, "engineering" = 6, "materials" = 6, "programming" = 6)
	build_path = /obj/item/paintkit/phazon_imperion
	materials = list(MAT_METAL=50000, MAT_DIAMOND=4000, MAT_BLUESPACE=4000)
	construction_time = 40 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_phazon_janus
	name = "Phazon \"Janus\""
	id = "p_janus"
	build_type = MECHFAB
	req_tech = list("bluespace" = 7, "engineering" = 6, "materials" = 6, "programming" = 6)
	build_path = /obj/item/paintkit/phazon_janus
	materials = list(MAT_METAL=50000, MAT_DIAMOND=4000, MAT_BLUESPACE=4000)
	construction_time = 40 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_phazon_plazmus
	name = "Phazon \"Plazmus\""
	id = "p_plazmus"
	build_type = MECHFAB
	req_tech = list("bluespace" = 7, "engineering" = 6, "materials" = 6)
	build_path = /obj/item/paintkit/phazon_plazmus
	materials = list(MAT_METAL=50000, MAT_DIAMOND=4000, MAT_PLASMA=5000)
	construction_time = 40 SECONDS
	category = list("Exosuit Paintkits")

/datum/design/paint_phazon_blanco
	name = "Phazon \"Blanco\""
	id = "p_blanco"
	build_type = MECHFAB
	req_tech = list("bluespace" = 7, "engineering" = 7, "materials" = 7)
	build_path = /obj/item/paintkit/phazon_blanco
	materials = list(MAT_METAL=50000, MAT_DIAMOND=4000, MAT_BLUESPACE=4000)
	construction_time = 40 SECONDS
	category = list("Exosuit Paintkits")
