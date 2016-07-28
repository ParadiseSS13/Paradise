/* Example for reference when defining recipes
/datum/crafting_recipe/food
	name = ""			//in-game display name
	reqs[] = list()		//type paths of items/reagents consumed associated with how many are needed (equivalent to var/list/items and var/list/reagents combined)
	result				//type path of item resulting from this craft
	tools[] = list()	//type paths of items needed but not consumed
	time = 30			//time in deciseconds
	parts[] = list()	//type paths of items that will be placed in the result
	fruit[] = list()	//grown products required by the recipe
*/

/datum/crafting_recipe/sandwich
	name = "Sandwich"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak = 1,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice = 2,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sandwich
	category = CAT_FOOD

/datum/crafting_recipe/slimesandwich
	name = "Slime Jelly Sandwich"
	reqs = list(
		/datum/reagent/slimejelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice = 2,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime
	category = CAT_FOOD

/datum/crafting_recipe/cherrysandwich
	name = "Cherry Jelly Sandwich"
	reqs = list(
		/datum/reagent/cherryjelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice = 2,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry
	category = CAT_FOOD

/datum/crafting_recipe/slimeburger
	name = "Slime Jelly Burger"
	reqs = list(
		/datum/reagent/slimejelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime
	category = CAT_FOOD

/datum/crafting_recipe/jellyburger
	name = "Cherry Jelly Burger"
	reqs = list(
		/datum/reagent/cherryjelly = 5,
		/obj/item/weapon/reagent_containers/food/snacks/bun = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry
	category = CAT_FOOD

/* Temporarily disabled until we can find a workaround for this fruit shit.
/datum/crafting_recipe/herbsalad
	name = "herb salad"
	fruit = list("ambrosia" = 3, "apple" = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/herbsalad

/datum/crafting_recipe/herbsalad/AdjustChems(var/obj/resultobj as obj)
	if(istype(resultobj, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RC = resultobj
		RC.reagents.del_reagent("toxin")

/datum/crafting_recipe/aesirsalad
	name = "Aesir salad"
	fruit = list("ambrosiadeus" = 3, "goldapple" = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/aesirsalad

/datum/crafting_recipe/validsalad
	name = "valid salad"
	fruit = list("ambrosia" = 3, "potato" = 1)
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatball = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/validsalad

/datum/crafting_recipe/validsalad/AdjustChems(var/obj/resultobj as obj)
	if(istype(resultobj, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RC = resultobj
		RC.reagents.del_reagent("toxin")

/datum/crafting_recipe/wrap
	name = "egg wrap"
	fruit = list("cabbage" = 1)
	reqs = list(
		/datum/reagent/soysauce = 10,
		/obj/item/weapon/reagent_containers/food/snacks/friedegg = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/wrap
*/

/datum/crafting_recipe/notasandwich
	name = "not-a-sandwich"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice = 2,
		/obj/item/clothing/mask/fakemoustache = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/notasandwich
	category = CAT_FOOD


/datum/crafting_recipe/sushi_Ebi
	name = "Ebi Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/boiled_shrimp = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Ebi
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Ikura
	name = "Ikura Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/salmon = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Ikura
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Inari
	name = "Inari Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/fried_tofu = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Inari
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Sake
	name = "Sake Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/salmonmeat = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Sake
	category = CAT_FOOD

/datum/crafting_recipe/sushi_SmokedSalmon
	name = "Smoked Salmon Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/salmonsteak = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_SmokedSalmon
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Masago
	name = "Masago Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/goldfish = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Masago
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Tobiko
	name = "Tobiko Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/fish_eggs/shark = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Tobiko
	category = CAT_FOOD

/datum/crafting_recipe/sushi_TobikoEgg
	name = "Tobiko and Egg Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/sushi_Tobiko = 1,
		/obj/item/weapon/reagent_containers/food/snacks/egg = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_TobikoEgg
	category = CAT_FOOD

/datum/crafting_recipe/sushi_Tai
	name = "Tai Sushi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/boiledrice = 1,
		/obj/item/weapon/reagent_containers/food/snacks/catfishmeat = 1,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sushi_Tai
	category = CAT_FOOD
