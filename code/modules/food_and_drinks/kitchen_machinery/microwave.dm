
/obj/machinery/kitchen_machine/microwave
	name = "микроволновка"
	desc = "Микроволновка. Идеальна для перенагревания вещей излучением."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	cook_verbs = list("Microwaving", "Reheating", "Heating")
	recipe_type = RECIPE_MICROWAVE
	off_icon = "mw"
	on_icon = "mw1"
	dirty_icon = "mwbloody"
	open_icon = "mw-o"
	pass_flags = PASSTABLE
	soundloop_type = /datum/looping_sound/kitchen/microwave

// see code/modules/food/recipes_microwave.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/microwave/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/microwave(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/kitchen_machine/microwave/upgraded/Initialize(mapload)
	. = ..()
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
