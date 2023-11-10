/obj/machinery/mecha_part_fabricator/Initialize(mapload)
	. = ..()
	// Set up some datums
	var/datum/component/material_container/materials = AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE), 0, FALSE, /obj/item/stack, CALLBACK(src, PROC_REF(can_insert_materials)), CALLBACK(src, PROC_REF(on_material_insert)))
	materials.precise_insertion = TRUE
	local_designs = new /datum/research(src)

	// Components
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mechfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

	categories = list(
		"Cyborg",
		"Cyborg Repair",
		"MODsuit Construction",
		"MODsuit Modules",
		"Ripley",
		"Firefighter",
		"Odysseus",
		"Gygax",
		"Durand",
		"H.O.N.K",
		"Reticence",
		"Executioner",
		"Phazon",
		"Exosuit Equipment",
		"Cyborg Upgrade Modules",
		"Medical",
		"Misc"
	)
