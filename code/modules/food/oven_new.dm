
/obj/machinery/kitchen_machine/oven
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"
	cook_verbs = list("Baking", "Roasting", "Broiling")
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
	if (!available_recipes)
		available_recipes = new
		for (var/type in (typesof(/datum/recipe/oven)-/datum/recipe/oven))
			var/datum/recipe/recipe = new type
			if(recipe.result) // Ignore recipe subtypes that lack a result
				available_recipes += recipe
			else
				qdel(recipe)
		acceptable_items = new
		acceptable_reagents = new
		for (var/datum/recipe/oven/recipe in available_recipes)
			for (var/item in recipe.items)
				acceptable_items |= item
			for (var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
			if (recipe.items)
				max_n_of_items = max(max_n_of_items,recipe.count_n_items())
		acceptable_items |= /obj/item/weapon/reagent_containers/food/snacks/grown

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
