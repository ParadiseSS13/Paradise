
/obj/machinery/kitchen_machine/microwave
	name = "Microwave"
	desc = "A microwave, perfect for reheating things with radiation."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	cook_verbs = list("Microwaving", "Reheating", "Heating")
	off_icon = "mw"
	on_icon = "mw1"
	broken_icon = "mwb"
	dirty_icon = "mwbloody"
	open_icon = "mw-o"

// see code/modules/food/recipes_microwave.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/microwave/New()
	..()
	if (!available_recipes)
		available_recipes = new
		for (var/type in (typesof(/datum/recipe/microwave)-/datum/recipe/microwave))
			var/datum/recipe/recipe = new type
			if(recipe.result) // Ignore recipe subtypes that lack a result
				available_recipes += recipe
			else
				qdel(recipe)
		acceptable_items = new
		acceptable_reagents = new
		for (var/datum/recipe/microwave/recipe in available_recipes)
			for (var/item in recipe.items)
				acceptable_items |= item
			for (var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
			if (recipe.items)
				max_n_of_items = max(max_n_of_items,recipe.count_n_items())
		acceptable_items |= /obj/item/weapon/reagent_containers/food/snacks/grown

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/microwave(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/kitchen_machine/microwave/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/microwave(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()

/obj/machinery/kitchen_machine/microwave/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	efficiency = E
