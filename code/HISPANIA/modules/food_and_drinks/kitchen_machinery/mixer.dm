/obj/machinery/kitchen_machine/mixer
	name = "mixer"
	desc = "A high-speed mixer."
	icon = 'icons/HISPANIA/obj/cooking_machines.dmi'
	icon_state = "mixer_off"
	cook_verbs = list("Wonderizing", "Scrumpdiddlyumptiousification", "Miracle-coating", "Flavorifaction")
	recipe_type = RECIPE_MIXER
	off_icon = "mixer_off"
	on_icon = "mixer_on"
	broken_icon = "mixer_broke"
	dirty_icon = "mixer_dirty"
	open_icon = "mixer_open"

// see code/modules/food/recipes_candy.dm for recipes

/*******************
*   Initialising
********************/
/obj/machinery/kitchen_machine/mixer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mixer(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/mixer/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mixer(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/mixer/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E
