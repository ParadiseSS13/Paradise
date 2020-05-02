/proc/get_random_food()
	var/list/blocked = list(/obj/item/reagent_containers/food/snacks,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/sliceable,
		/obj/item/reagent_containers/food/snacks/margheritaslice,
		/obj/item/reagent_containers/food/snacks/meatpizzaslice,
		/obj/item/reagent_containers/food/snacks/mushroompizzaslice,
		/obj/item/reagent_containers/food/snacks/vegetablepizzaslice,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat/slab,
		/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/deepfryholder
		)
	blocked |= typesof(/obj/item/reagent_containers/food/snacks/customizable)
	return pick(subtypesof(/obj/item/reagent_containers/food/snacks) - blocked)

/proc/get_random_drink()
	var/list/blocked = list(/obj/item/reagent_containers/food/drinks/cans/adminbooze,
							/obj/item/reagent_containers/food/drinks/cans/madminmalt,
							/obj/item/reagent_containers/food/drinks/shaker,
							/obj/item/reagent_containers/food/drinks/britcup,
							/obj/item/reagent_containers/food/drinks/sillycup,
							/obj/item/reagent_containers/food/drinks/cans,
							/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass,
							/obj/item/reagent_containers/food/drinks/drinkingglass,
							/obj/item/reagent_containers/food/drinks/bottle,
							/obj/item/reagent_containers/food/drinks/mushroom_bowl
							)
	blocked += typesof(/obj/item/reagent_containers/food/drinks/flask)
	blocked += typesof(/obj/item/reagent_containers/food/drinks/trophy)
	blocked += typesof(/obj/item/reagent_containers/food/drinks/cans/bottler)
	return pick(subtypesof(/obj/item/reagent_containers/food/drinks) - blocked)
