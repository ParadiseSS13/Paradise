
/obj/machinery/kitchen_machine/candy_maker
	name = "candy machine"
	desc = "The stuff of nightmares for a dentist."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "candymaker_off"
	cook_verbs = list("Wonderizing", "Scrumpdiddlyumptiousification", "Miracle-coating", "Flavorifaction")
	recipe_type = /datum/recipe/candy
	off_icon = "candymaker_off"
	on_icon = "candymaker_on"
	broken_icon = "candymaker_broke"
	dirty_icon = "candymaker_dirty"
	open_icon = "candymaker_open"

// see code/modules/food/recipes_candy.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/candy_maker/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/candy_maker(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/candy_maker/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/candy_maker(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/candy_maker/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E
