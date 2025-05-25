/datum/crafting_recipe/sandwich
	name = "Sandwich"
	reqs = list(
		/obj/item/food/meatsteak = 1,
		/obj/item/food/sliced/bread = 2,
		/obj/item/food/sliced/cheesewedge = 1,
	)
	result = list(/obj/item/food/sandwich)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/slimesandwich
	name = "Slime Jelly Sandwich"
	reqs = list(
		/datum/reagent/slimejelly = 5,
		/obj/item/food/sliced/bread = 2,
	)
	result = list(/obj/item/food/jellysandwich/slime)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/cherrysandwich
	name = "Cherry Jelly Sandwich"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/sliced/bread = 2,
	)
	result = list(/obj/item/food/jellysandwich/cherry)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/slimeburger
	name = "Slime Jelly Burger"
	reqs = list(
		/datum/reagent/slimejelly = 5,
		/obj/item/food/bun = 1,
	)
	result = list(/obj/item/food/burger/jelly/slime)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/jellyburger
	name = "Cherry Jelly Burger"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/bun = 1,
	)
	result = list(/obj/item/food/burger/jelly/cherry)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/baseballburger
	name = "Home run baseball burger"
	reqs = list(
		/obj/item/melee/baseball_bat = 1,
		/obj/item/food/bun = 1,
	)
	result = list(/obj/item/food/burger/baseball)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/notasandwich
	name = "not-a-sandwich"
	reqs = list(
		/obj/item/food/sliced/bread = 2,
		/obj/item/clothing/mask/fakemoustache = 1,
	)
	result = list(/obj/item/food/notasandwich)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/sushi_ebi
	name = "Ebi Sushi"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/boiled_shrimp = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/sliced/sushi_ebi)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/ebi_maki
	name = "Ebi Maki Roll"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/boiled_shrimp = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/reagent_containers/cooking/sushimat)
	result = list(/obj/item/food/sliceable/ebi_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_ikura
	name = "Ikura Sushi"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/fish_eggs/salmon = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/sliced/sushi_ikura)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/ikura_maki
	name = "Ikura Maki Roll"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/fish_eggs/salmon = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/reagent_containers/cooking/sushimat)
	result = list(/obj/item/food/sliceable/ikura_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_inari
	name = "Inari Sushi"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/fried_tofu = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/sliced/sushi_inari)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/inari_maki
	name = "Inari Maki Roll"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/fried_tofu = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/reagent_containers/cooking/sushimat)
	result = list(/obj/item/food/sliceable/inari_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_sake
	name = "Sake Sushi"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/salmonmeat = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/sliced/sushi_sake)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sake_maki
	name = "Sake Maki Roll"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/salmonmeat = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/reagent_containers/cooking/sushimat)
	result = list(/obj/item/food/sliceable/sake_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_smoked_salmon
	name = "Smoked Salmon Sushi"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/salmonsteak = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/sliced/sushi_smoked_salmon)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/smoked_salmon_maki
	name = "Smoked Salmon Maki Roll"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/salmonsteak = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/reagent_containers/cooking/sushimat)
	result = list(/obj/item/food/sliceable/smoked_salmon_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_masago
	name = "Masago Sushi"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/fish_eggs/goldfish = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/sliced/sushi_masago)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/masago_maki
	name = "Masago Maki Roll"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/fish_eggs/goldfish = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/reagent_containers/cooking/sushimat)
	result = list(/obj/item/food/sliceable/masago_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_tobiko
	name = "Tobiko Sushi"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/fish_eggs/shark = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/sliced/sushi_tobiko)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/tobiko_maki
	name = "Tobiko Maki Roll"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/fish_eggs/shark = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/reagent_containers/cooking/sushimat)
	result = list(/obj/item/food/sliceable/tobiko_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_tobiko_egg
	name = "Tobiko and Egg Sushi"
	reqs = list(
		/obj/item/food/sliced/sushi_tobiko = 1,
		/obj/item/food/egg = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/sliced/sushi_tobiko_egg)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/tobiko_egg_maki
	name = "Tobiko and Egg Maki Roll"
	reqs = list(
		/obj/item/food/sliced/sushi_tobiko = 4,
		/obj/item/food/egg = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/reagent_containers/cooking/sushimat)
	result = list(/obj/item/food/sliceable/tobiko_egg_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_tai
	name = "Tai Sushi"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/catfishmeat = 1,
		/obj/item/stack/seaweed = 1,
	)
	result = list(/obj/item/food/sliced/sushi_tai)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/tai_maki
	name = "Tai Maki Roll"
	reqs = list(
		/obj/item/food/boiledrice = 1,
		/obj/item/food/catfishmeat = 4,
		/obj/item/stack/seaweed = 1,
	)
	pathtools = list(/obj/item/reagent_containers/cooking/sushimat)
	result = list(/obj/item/food/sliceable/tai_maki)
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
		/obj/item/food/sliceable/birthdaycake  = 1,
		/obj/item/food/meat  = 3,
		/datum/reagent/blood = 30,
		/datum/reagent/consumable/sprinkles = 5,
		/datum/reagent/teslium = 1,
	)
	result = list(/mob/living/simple_animal/pet/cat/cak)
	category = CAT_FOOD
	subcategory = CAT_CAKE //Cat! Haha, get it? CAT? GET IT? We get it - Love Felines -Foxes are better
