
/obj/machinery/kitchen_machine/oven
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"
	cook_verbs = list("Baking", "Roasting", "Broiling")
	recipe_type = /datum/recipe/oven
	off_icon = "oven_off"
	on_icon = "oven_on"
	broken_icon = "oven_broke"
	dirty_icon = "oven_dirty"
	open_icon = "oven_open"

// see code/modules/food/recipes_oven.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/oven/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/oven(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/oven/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/oven(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/oven/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	efficiency = round((E/2), 1) // There's 2 lasers, so halve the effect on the efficiency to keep it balanced
