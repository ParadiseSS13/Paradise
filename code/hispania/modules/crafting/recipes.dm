/datum/crafting_recipe/xenobluespacecell
	name = "Xenobluespace power cell"
	result = list(/obj/item/stock_parts/cell/xenoblue)
	reqs = list(/obj/item/stock_parts/cell/high/slime = 1,
				/obj/item/xenobluecellmaker = 1,
				/obj/item/stock_parts/cell/bluespace = 1
	)
	time = 15
	category = CAT_MISC

/datum/crafting_recipe/flowercrown
	name = "Flower Crown"
	result = list(/obj/item/clothing/head/flowercrown)
	time = 10
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/poppy = 5)
	category = CAT_MISC


/datum/crafting_recipe/femur_breaker
	name = "Femur Breaker"
	result = list(/obj/structure/femur_breaker)
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
	result = list(/obj/item/toy/balloon_h)
	reqs = list(/obj/item/stack/sheet/plastic = 5,
		        /obj/item/stack/cable_coil = 5)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/balloonm
	name = "Macdonalds balloon"
	result = list(/obj/item/toy/balloon_h/m)
	time = 15
	reqs = list(/obj/item/stack/sheet/plastic = 5,
		        /obj/item/stack/cable_coil = 5,
		        /obj/item/reagent_containers/food/snacks/monkeyburger = 1)
	category = CAT_DECORATIONS
	subcategory = CAT_HOLIDAY

/datum/crafting_recipe/ballooncorgi
	name = "Corgi balloon"
	result = list(/obj/item/toy/balloon_h/corgi)

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
	result = list(/obj/item/melee/woodensword)
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
	result = list(/obj/structure/chair/wheelchair/gold)
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
	result = list(/obj/item/roller/advanced)
	time = 40
	reqs = list(/obj/item/stack/cable_coil = 5,
		        /obj/item/roller = 1,
		        /obj/item/stack/rods = 10,
				/obj/item/healthanalyzer = 1)
	tools = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	category = CAT_MISC

///Hand Made Splint///
/datum/crafting_recipe/hand_made_splint
	name = "Hand Made Splint"
	result = list(/obj/item/stack/medical/splint/hand_made)
	time = 30
	reqs = list(/obj/item/stack/cable_coil = 10,
		        /obj/item/stack/tape_roll = 15,
		        /obj/item/stack/rods = 20)
	category = CAT_PRIMAL

/datum/crafting_recipe/earthly_cataplasm
	name = "Earthly Herbal Cataplasm"
	result = list(/obj/item/stack/medical/ointment/earthly_cataplasm)
	time = 40
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf = 4,
		        /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_cap = 4,
				/obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit = 4)

	category = CAT_PRIMAL

/datum/crafting_recipe/fiery_cataplasm
	name = "Fiery Herbal Cataplasm"
	result = list(/obj/item/stack/medical/ointment/earthly_cataplasm/fiery_cataplasm)
	time = 40
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf = 4,
		        /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_cap= 4,
		        /obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem = 4)
	category = CAT_PRIMAL

///Lavaland Stuff///
/datum/crafting_recipe/plaz_lamp
	name = "Plazmite Lamp"
	result = list(/obj/item/flashlight/lamp/plazlamp)
	time = 50
	reqs = list(/obj/item/stack/sheet/bone = 2,
				 /obj/item/stack/sheet/sinew = 3,
				 /obj/item/stack/sheet/cartiplaz = 6)
	category = CAT_PRIMAL

/datum/crafting_recipe/watchebelt
	name = "Sinew Belt"
	result = list(/obj/item/storage/belt/mining/primitive)
	time = 80
	reqs = list(/obj/item/stack/sheet/bone = 4,
				 /obj/item/stack/sheet/sinew = 4)
	category = CAT_PRIMAL

/datum/crafting_recipe/lighterbelt
	name = "Lighter Explorer's Webbing"
	result = list(/obj/item/storage/belt/mining/alt)
	time = 60
	reqs = list(/obj/item/storage/belt/mining = 1)
	pathtools = list(/obj/item/kitchen/knife)
	category = CAT_PRIMAL
