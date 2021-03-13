/datum/crafting_recipe/xenobluespacecell
	name = "Xenobluespace power cell"
	result = /obj/item/stock_parts/cell/xenoblue
	reqs = list(/obj/item/stock_parts/cell/high/slime = 1,
				/obj/item/xenobluecellmaker = 1,
				/obj/item/stock_parts/cell/bluespace = 1
	)
	time = 15
	category = CAT_MISC

/datum/crafting_recipe/flowercrown
	name = "Flower Crown"
	result = /obj/item/clothing/head/flowercrown
	time = 10
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/poppy = 5)
	category = CAT_MISC


/datum/crafting_recipe/femur_breaker
	name = "Femur Breaker"
	result = /obj/structure/femur_breaker
	time = 150
	reqs = list(/obj/item/stack/sheet/plasteel = 10,
				/obj/item/stack/rods = 20,
				/obj/item/stack/sheet/metal = 10,
		        /obj/item/stack/cable_coil = 30)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_WELDER)
	category = CAT_MISC

 ////////////////
//////Globos//////
 ////////////////
/datum/crafting_recipe/balloon
	name = "White balloon"
	time = 10
	result = /obj/item/toy/balloon_h
	reqs = list(/obj/item/stack/sheet/plastic = 5,
		        /obj/item/stack/cable_coil = 5)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/balloonm
	name = "Macdonalds balloon"
	result = /obj/item/toy/balloon_h/m
	time = 15
	reqs = list(/obj/item/stack/sheet/plastic = 5,
		        /obj/item/stack/cable_coil = 5,
		        /obj/item/reagent_containers/food/snacks/monkeyburger = 1)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/ballooncorgi
	name = "Corgi balloon"
	result = /obj/item/toy/balloon_h/corgi

	parts = list(/mob/living/simple_animal/pet/dog/corgi = 1)
	time = 10
	reqs = list(/obj/item/stack/sheet/plastic = 5,
		        /obj/item/stack/cable_coil = 5,
		        /obj/item/reagent_containers/food/snacks/meat/corgi = 1)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

///Wooden Sword///
/datum/crafting_recipe/woodensword
	name = "wooden sword"
	result = /obj/item/melee/woodensword
	time = 15
	reqs = list(/obj/item/stack/sheet/wood = 3,
				/obj/item/stack/tape_roll = 1)
	tools = list(TOOL_SCREWDRIVER,
				TOOL_WIRECUTTER)
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

///Silla de Oro///
/datum/crafting_recipe/gold_wheel23
	name = "Gold Wheel Chair"
	result = /obj/structure/chair/wheelchair/gold
	time = 60
	reqs = list(/obj/item/stack/cable_coil = 5,
		        /obj/item/stock_parts/cell = 1,
		        /obj/item/stack/rods = 5,
		        /obj/item/stack/sheet/metal = 10,
				/obj/item/stack/sheet/mineral/gold = 6)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_MISC

///Advanced Roller Bed///
/datum/crafting_recipe/adv_roller_bed
	name = "Advanced Roller Bed"
	result = /obj/item/roller/advanced
	time = 40
	reqs = list(/obj/item/stack/cable_coil = 5,
		        /obj/item/roller = 1,
		        /obj/item/stack/rods = 10,
				/obj/item/healthanalyzer = 1)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_MISC
