
/obj/machinery/kitchen_machine/candy_maker
	name = "candy machine"
	desc = "The stuff of nightmares for a dentist."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "candymaker_off"
	cook_verbs = list("Wonderizing", "Scrumpdiddlyumptiousification", "Miracle-coating", "Flavorifaction")
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
	if (!available_recipes)
		available_recipes = new
		for (var/type in (typesof(/datum/recipe/candy)-/datum/recipe/candy))
			var/datum/recipe/recipe = new type
			if(recipe.result) // Ignore recipe subtypes that lack a result
				available_recipes += recipe
			else
				qdel(recipe)
		acceptable_items = new
		acceptable_reagents = new
		for (var/datum/recipe/candy/recipe in available_recipes)
			for (var/item in recipe.items)
				acceptable_items |= item
			for (var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
			if (recipe.items)
				max_n_of_items = max(max_n_of_items,recipe.count_n_items())
		acceptable_items |= /obj/item/weapon/reagent_containers/food/snacks/grown

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
