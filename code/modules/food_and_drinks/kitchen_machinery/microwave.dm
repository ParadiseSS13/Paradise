
/obj/machinery/kitchen_machine/microwave
	name = "microwave"
	desc = "A microwave, perfect for reheating things with radiation."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	cook_verbs = list("Microwaving", "Reheating", "Heating")
	recipe_type = RECIPE_MICROWAVE
	off_icon = "mw"
	on_icon = "mw1"
	broken_icon = "mwb"
	dirty_icon = "mwbloody"
	open_icon = "mw-o"
	pass_flags = PASSTABLE

// see code/modules/food/recipes_microwave.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/microwave/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/microwave(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/kitchen_machine/microwave/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/microwave(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/kitchen_machine/microwave/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	efficiency = E

// The following code is present as temporary assurance for compatibility and to avoid merge conflicts for the TG mining port
// Please delete this portion once all maps are updated to use the new object path: /obj/machinery/kitchen_machine/microwave

/obj/machinery/microwave
	name = "Microwave spawner"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"

/obj/machinery/microwave/New()
	new /obj/machinery/kitchen_machine/microwave(get_turf(src))
	qdel(src)