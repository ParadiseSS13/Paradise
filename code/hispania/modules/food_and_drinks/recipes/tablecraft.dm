/datum/crafting_recipe/avocadosandwich
	name = "Avocado Sandwich"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/avocadoslice = 2,
		/obj/item/reagent_containers/food/snacks/toast = 2,
		/obj/item/reagent_containers/food/condiment/mayonnaise = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/avocadosandwich)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/baconrolled
	name = "Rolls of Bacon with Avocado"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/avocadoslice = 1,
		/obj/item/reagent_containers/food/snacks/bacon = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/baconrolled)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/salmoncreamtoast
	name = "Salmon Cream cheese toast"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/baguette = 1,
		/obj/item/reagent_containers/food/snacks/smokedsalmon = 1,
		/obj/item/reagent_containers/food/snacks/cream_cheese = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/salmoncreamtoast)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH
