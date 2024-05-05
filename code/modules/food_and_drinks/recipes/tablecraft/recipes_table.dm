/datum/crafting_recipe/sandwich
	name = "Sandwich"
	reqs = list(
		/obj/item/food/snacks/meatsteak = 1,
		/obj/item/food/snacks/breadslice = 2,
		/obj/item/food/snacks/cheesewedge = 1,
	)
	result = list(/obj/item/food/snacks/sandwich)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/slimesandwich
	name = "Slime Jelly Sandwich"
	reqs = list(
		/datum/reagent/slimejelly = 5,
		/obj/item/food/snacks/breadslice = 2,
	)
	result = list(/obj/item/food/snacks/jellysandwich/slime)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/cherrysandwich
	name = "Cherry Jelly Sandwich"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/snacks/breadslice = 2,
	)
	result = list(/obj/item/food/snacks/jellysandwich/cherry)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/slimeburger
	name = "Slime Jelly Burger"
	reqs = list(
		/datum/reagent/slimejelly = 5,
		/obj/item/food/snacks/bun = 1,
	)
	result = list(/obj/item/food/snacks/burger/jelly/slime)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/jellyburger
	name = "Cherry Jelly Burger"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/snacks/bun = 1,
	)
	result = list(/obj/item/food/snacks/burger/jelly/cherry)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/baseballburger
	name = "Home run baseball burger"
	reqs = list(
		/obj/item/melee/baseball_bat = 1,
		/obj/item/food/snacks/bun = 1,
	)
	result = list(/obj/item/food/snacks/burger/baseball)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/notasandwich
	name = "not-a-sandwich"
	reqs = list(
		/obj/item/food/snacks/breadslice = 2,
		/obj/item/clothing/mask/fakemoustache = 1,
	)
	result = list(/obj/item/food/snacks/notasandwich)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/sushi_Ebi
	name = "Ebi Sushi"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/food/snacks/boiled_shrimp = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/snacks/sushi_Ebi)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Ebi_maki
	name = "Ebi Maki Roll"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/food/snacks/boiled_shrimp = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/food/snacks/sliceable/Ebi_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Ikura
	name = "Ikura Sushi"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/salmon = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/snacks/sushi_Ikura)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Ikura_maki
	name = "Ikura Maki Roll"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/salmon = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/food/snacks/sliceable/Ikura_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Inari
	name = "Inari Sushi"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/food/snacks/fried_tofu = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/snacks/sushi_Inari)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Inari_maki
	name = "Inari Maki Roll"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/food/snacks/fried_tofu = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/food/snacks/sliceable/Inari_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Sake
	name = "Sake Sushi"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/food/snacks/salmonmeat = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/snacks/sushi_Sake)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Sake_maki
	name = "Sake Maki Roll"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/food/snacks/salmonmeat = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/food/snacks/sliceable/Sake_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_SmokedSalmon
	name = "Smoked Salmon Sushi"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/food/snacks/salmonsteak = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/snacks/sushi_SmokedSalmon)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/SmokedSalmon_maki
	name = "Smoked Salmon Maki Roll"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/food/snacks/salmonsteak = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/food/snacks/sliceable/SmokedSalmon_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Masago
	name = "Masago Sushi"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/goldfish = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/snacks/sushi_Masago)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Masago_maki
	name = "Masago Maki Roll"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/goldfish = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/food/snacks/sliceable/Masago_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Tobiko
	name = "Tobiko Sushi"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/shark = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/snacks/sushi_Tobiko)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Tobiko_maki
	name = "Tobiko Maki Roll"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/shark = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/food/snacks/sliceable/Tobiko_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_TobikoEgg
	name = "Tobiko and Egg Sushi"
	reqs = list(
		/obj/item/food/snacks/sushi_Tobiko = 1,
		/obj/item/food/snacks/egg = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/snacks/sushi_TobikoEgg)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/TobikoEgg_maki
	name = "Tobiko and Egg Maki Roll"
	reqs = list(
		/obj/item/food/snacks/sushi_Tobiko = 4,
		/obj/item/food/snacks/egg = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/food/snacks/sliceable/TobikoEgg_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Tai
	name = "Tai Sushi"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/food/snacks/catfishmeat = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/snacks/sushi_Tai)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Tai_maki
	name = "Tai Maki Roll"
	reqs = list(
		/obj/item/food/snacks/boiledrice = 1,
		/obj/item/food/snacks/catfishmeat = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/food/snacks/sliceable/Tai_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/food

/datum/crafting_recipe/food/New()
	parts |= reqs

/datum/crafting_recipe/food/cak
	name = "Living cat/cake hybrid"
	reqs = list(
		/obj/item/organ/internal/brain = 1,
		/obj/item/organ/internal/heart = 1,
		/obj/item/food/snacks/sliceable/birthdaycake  = 1,
		/obj/item/food/snacks/meat  = 3,
		/datum/reagent/blood = 30,
		/datum/reagent/consumable/sprinkles = 5,
		/datum/reagent/teslium = 1,
	)
	result = list(/mob/living/simple_animal/pet/cat/cak)
	category = CAT_FOOD
	subcategory = CAT_CAKE //Cat! Haha, get it? CAT? GET IT? We get it - Love Felines -Foxes are better
