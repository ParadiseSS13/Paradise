/obj/machinery/chem_dispenser/botanical
	name = "ботанический химический раздатчик"
	desc = "Химический раздатчик, разработанный специально для ботаников."
	ui_title = "Ботанический Хим. Раздатчик"
	dispensable_reagents = list("mutagen", "saltpetre", "ammonia", "water")
	upgrade_reagents = list("atrazine", "glyphosate", "pestkiller", "diethylamine", "ash")

/obj/machinery/chem_dispenser/botanical/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser/botanical(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()
	dispensable_reagents = sortList(dispensable_reagents)

/obj/machinery/chem_dispenser/botanical/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser/botanical(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null)
	RefreshParts()

/obj/item/circuitboard/chem_dispenser/botanical
	name = "печатная плата (Ботанический Хим. Раздатчик)"
	build_path = /obj/machinery/chem_dispenser/botanical

/datum/design/botanical_dispenser
	name = "Machine Board (Ботанический Раздатчик)"
	desc = "Плата для ботанического хим. раздатчика."
	id = "botanical_dispenser"
	req_tech = list("programming" = 5, "biotech" = 3, "materials" = 4, "plasmatech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/chem_dispenser/botanical
	category = list("Misc. Machinery")
