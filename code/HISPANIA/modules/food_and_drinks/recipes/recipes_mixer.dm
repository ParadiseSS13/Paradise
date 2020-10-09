/datum/recipe/mixer/butter
	reagents = list("cream" = 20, "sodiumchloride" = 1)
	result = /obj/item/reagent_containers/food/snacks/butter

/datum/recipe/mixer/mayonnaise
	reagents = list("egg" = 30, "sodiumchloride" = 1, "cornoil" = 5)
	result = /obj/item/reagent_containers/food/condiment/mayonnaise

/datum/recipe/mixer/garlic_snack
	reagents = list("guacamole" = 10, "sodiumchloride" = 2, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/baguette,
		)
	result = /obj/item/reagent_containers/food/snacks/garlic_snack
