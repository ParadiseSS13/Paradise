/datum/crafting_recipe/xenobluespacecell
	name = "Xenobluespace power cell"
	result = /obj/item/stock_parts/cell/xenoblue
	reqs = list(/obj/item/stock_parts/cell/high/slime = 1,
				/obj/item/stock_parts/capacitor/quadratic = 1,
				/obj/item/xenobluecellmaker = 1,
				/obj/item/stock_parts/cell/bluespace = 1,
				/obj/item/stock_parts/micro_laser/quadultra  = 1)
	time = 30
	category = CAT_ROBOT


/datum/crafting_recipe/flowercrown
	name = "Flower Crown"
	result = /obj/item/clothing/head/flowercrown
	time = 10
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/poppy = 5)
	category = CAT_MISC
