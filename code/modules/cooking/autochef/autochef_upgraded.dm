RESTRICT_TYPE(/obj/machinery/autochef/upgraded)

/obj/machinery/autochef/upgraded

/obj/machinery/autochef/upgraded/Initialize(mapload)
	. = ..()

	makeSpeedProcess()

	component_parts = list()
	component_parts += new /obj/item/circuitboard/autochef(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/micro_laser/quadultra(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)

	RefreshParts()
