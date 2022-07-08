/* Example for reference when defining recipes
/datum/crafting_recipe/food
	name = ""			//in-game display name
	reqs[] = list()		//type paths of items/reagents consumed associated with how many are needed (equivalent to var/list/items and var/list/reagents combined)
	result				//type path of item resulting from this craft
	tools[] = list()	//type paths of items needed but not consumed
	time = 30			//time in deciseconds
	parts[] = list()	//type paths of items that will be placed in the result
*/

/datum/crafting_recipe/sandwich
	name = "Sandwich"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meatsteak = 1,
		/obj/item/reagent_containers/food/snacks/breadslice = 2,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/sandwich)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/slimesandwich
	name = "Slime Jelly Sandwich"
	reqs = list(
		/datum/reagent/slimejelly = 5,
		/obj/item/reagent_containers/food/snacks/breadslice = 2,
	)
	result = list(/obj/item/reagent_containers/food/snacks/jellysandwich/slime)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/cherrysandwich
	name = "Cherry Jelly Sandwich"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/reagent_containers/food/snacks/breadslice = 2,
	)
	result = list(/obj/item/reagent_containers/food/snacks/jellysandwich/cherry)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/slimeburger
	name = "Slime Jelly Burger"
	reqs = list(
		/datum/reagent/slimejelly = 5,
		/obj/item/reagent_containers/food/snacks/bun = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/jellyburger/slime)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/jellyburger
	name = "Cherry Jelly Burger"
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/reagent_containers/food/snacks/bun = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/jellyburger/cherry)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/baseballburger
	name = "Home run baseball burger"
	reqs = list(
		/obj/item/melee/baseball_bat = 1,
		/obj/item/reagent_containers/food/snacks/bun = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/baseballburger)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/notasandwich
	name = "not-a-sandwich"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/breadslice = 2,
		/obj/item/clothing/mask/fakemoustache = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/notasandwich)
	category = CAT_FOOD
	subcategory = CAT_SANDWICH

/datum/crafting_recipe/sushi_Ebi
	name = "Ebi Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/boiled_shrimp = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/sushi_Ebi)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Ebi_maki
	name = "Ebi Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/boiled_shrimp = 4,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/reagent_containers/food/snacks/sliceable/Ebi_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Ikura
	name = "Ikura Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/salmon = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/sushi_Ikura)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Ikura_maki
	name = "Ikura Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/salmon = 4,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/reagent_containers/food/snacks/sliceable/Ikura_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Inari
	name = "Inari Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/fried_tofu = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/sushi_Inari)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Inari_maki
	name = "Inari Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/fried_tofu = 4,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/reagent_containers/food/snacks/sliceable/Inari_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Sake
	name = "Sake Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/salmonmeat = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/sushi_Sake)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Sake_maki
	name = "Sake Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/salmonmeat = 4,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/reagent_containers/food/snacks/sliceable/Sake_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_SmokedSalmon
	name = "Smoked Salmon Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/salmonsteak = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/sushi_SmokedSalmon)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/SmokedSalmon_maki
	name = "Smoked Salmon Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/salmonsteak = 4,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/reagent_containers/food/snacks/sliceable/SmokedSalmon_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Masago
	name = "Masago Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/goldfish = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/sushi_Masago)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Masago_maki
	name = "Masago Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/goldfish = 4,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/reagent_containers/food/snacks/sliceable/Masago_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Tobiko
	name = "Tobiko Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/shark = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/sushi_Tobiko)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Tobiko_maki
	name = "Tobiko Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/shark = 4,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/reagent_containers/food/snacks/sliceable/Tobiko_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_TobikoEgg
	name = "Tobiko and Egg Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sushi_Tobiko = 1,
		/obj/item/reagent_containers/food/snacks/egg = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/sushi_TobikoEgg)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/TobikoEgg_maki
	name = "Tobiko and Egg Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sushi_Tobiko = 4,
		/obj/item/reagent_containers/food/snacks/egg = 4,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/reagent_containers/food/snacks/sliceable/TobikoEgg_maki)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/sushi_Tai
	name = "Tai Sushi"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/catfishmeat = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/sushi_Tai)
	category = CAT_FOOD
	subcategory = CAT_SUSHI

/datum/crafting_recipe/Tai_maki
	name = "Tai Maki Roll"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/catfishmeat = 4,
	)
	pathtools = list(/obj/item/kitchen/sushimat)
	result = list(/obj/item/reagent_containers/food/snacks/sliceable/Tai_maki)
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
		/obj/item/reagent_containers/food/snacks/sliceable/birthdaycake  = 1,
		/obj/item/reagent_containers/food/snacks/meat  = 3,
		/datum/reagent/blood = 30,
		/datum/reagent/consumable/sprinkles = 5,
		/datum/reagent/teslium = 1,
	)
	result = list(/mob/living/simple_animal/pet/cat/cak)
	category = CAT_FOOD
	subcategory = CAT_CAKE //Cat! Haha, get it? CAT? GET IT? We get it - Love Felines -Foxes are better


/* PIZZA RECIPIES */
/datum/crafting_recipe/margheritapizza
	name = "Uncooked Margherita Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 2,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/margheritapizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/cheesepizza
	name = "Uncooked Cheese Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 4,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/cheesepizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/pepperonipizza
	name = "Uncooked Pepperoni Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/sausage = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/pepperonipizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/macpizza
	name = "Uncooked Mac 'n' Cheese Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 2,
		/obj/item/reagent_containers/food/snacks/macncheese = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/macpizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/meatpizza
	name = "Uncooked Meat Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/meat = 3,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/meatpizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/mushroompizza
	name = "Uncooked Mushroom Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/mushroom = 5,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/mushroompizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/vegetablepizza
	name = "Uncooked Vegetable Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/eggplant = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/reagent_containers/food/snacks/grown/corn = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/vegetablepizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/hawaiianpizza
	name = "Uncooked Hawaiian Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/pineappleslice = 2,
		/obj/item/reagent_containers/food/snacks/meat = 1,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/hawaiianpizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/donkpocketpizza
	name = "Uncooked Donk-pocket Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/donkpocket = 2,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/donkpocketpizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/dankpizza
	name = "Uncooked Dank Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/cannabis = 4,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/dankpizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/firecrackerpizza
	name = "Uncooked Firecracker Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/chili = 3,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/firecrackerpizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/pestopizza
	name = "Uncooked \"Pesto\" Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 2,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/datum/reagent/consumable/wasabi = 5,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/pestopizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA

/datum/crafting_recipe/garlicpizza
	name = "Uncooked Garlic Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough = 1,
		/obj/item/reagent_containers/food/snacks/grown/garlic = 2,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/datum/reagent/consumable/garlic = 5,
	)
	result = list(/obj/item/reagent_containers/food/snacks/rawpizza/garlicpizza)
	category = CAT_FOOD
	subcategory = CAT_PIZZA
