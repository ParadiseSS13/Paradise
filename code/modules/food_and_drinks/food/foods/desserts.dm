//////////////////////
//		Misc		//
//////////////////////

/obj/item/food/friedbanana
	name = "fried banana"
	desc = "Goreng Pisang, also known as fried bananas."
	icon_state = "friedbanana"
	list_reagents = list("sugar" = 5, "nutriment" = 8, "cornoil" = 4)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/ricepudding
	name = "rice pudding"
	desc = "Where's the Jam!"
	icon_state = "rpudding"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FFFBDB"
	list_reagents = list("nutriment" = 7, "vitamin" = 2)
	tastes = list("rice" = 1, "sweetness" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/spacylibertyduff
	name = "spacy liberty duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#42B873"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "psilocybin" = 6)
	tastes = list("jelly" = 1, "mushroom" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/amanitajelly
	name = "amanita jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ED0758"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "amanitin" = 6, "psilocybin" = 3)
	tastes = list("jelly" = 1, "mushroom" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/candiedapple
	name = "candied apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	filling_color = "#F21873"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "sugar" = 2)
	tastes = list("apple" = 2, "sweetness" = 2)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon_state = "mint"
	bitesize = 1
	filling_color = "#F2F2F2"
	list_reagents = list("minttoxin" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/tapioca_pudding
	name = "tapioca pudding"
	desc = "A bubbly and sweet pudding."
	icon_state = "tapiocapudding"
	bitesize = 4
	filling_color = "#c4c5bb"
	list_reagents = list("sugar" = 3, "milk" = 2)
	tastes = list("vanilla" = 2, "chewiness" = 1)
	goal_difficulty = FOOD_GOAL_HARD

//////////////////////
//	Mug Cakes from Hispania!	//
//////////////////////
/obj/item/food/mugcake
	name = "mugcake"
	desc = "A delicious and spongy little cake inside a coffee mug."
	icon = 'icons/obj/food/bakedgoods.dmi'
	icon_state = "mugcake"
	trash = /obj/item/reagent_containers/drinks/mug
	filling_color = "#EFD8A7"
	list_reagents = list("nutriment" = 6)

/obj/item/food/mugcake/Initialize(mapload, obj/item/container)
	. = ..()
	if(istype(container, /obj/item/reagent_containers/drinks/mug))
		trash = container
		container.forceMove(src)
	else
		trash = new /obj/item/reagent_containers/drinks/mug(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/food/mugcake/update_overlays()
	. = ..()

	if(istype(trash, /obj/item/reagent_containers/drinks/mug))
		var/obj/item/reagent_containers/drinks/mug/base_mug = trash
		. += image(base_mug.icon, base_mug.icon_state)
	else
		. += image(/obj/item/reagent_containers/drinks/mug::icon, /obj/item/reagent_containers/drinks/mug::icon_state)
	. += image(icon, icon_state)

/obj/item/food/mugcake/vanilla
	name = "vanilla Mugcake"
	desc = "A delicious and spongy little vanilla cake inside a coffee mug."
	icon_state = "vanilla_mugcake"
	filling_color = "#5E5042"
	list_reagents = list("nutriment" = 7)

/obj/item/food/mugcake/chocolate
	name = "chocolate Mugcake"
	desc = "A delicious and spongy little chocolate cake inside a coffee mug."
	icon_state = "chocolate_mugcake"
	filling_color = "#5E5042"
	list_reagents = list("nutriment" = 7)

/obj/item/food/mugcake/banana
	name = "banana Mugcake"
	desc = "A delicious and spongy little banana cake inside a coffee mug."
	icon_state = "banana_mugcake"
	filling_color = "#FFD351"
	list_reagents = list("nutriment" = 7)

/obj/item/food/mugcake/cherry
	name = "cherry Mugcake"
	desc = "A delicious and spongy little cherry cake inside a coffee mug."
	icon_state = "cherry_mugcake"
	filling_color = "#51AEFF"
	list_reagents = list("nutriment" = 7)

/obj/item/food/mugcake/bluecherry
	name = "blue Cherry Mugcake"
	desc = "A delicious and spongy little blue cherry cake inside a coffee mug."
	icon_state = "bluecherry_mugcake"
	filling_color = "#FF5459"
	list_reagents = list("nutriment" = 7)

/obj/item/food/mugcake/lime
	name = "lime Mugcake"
	desc = "A delicious and spongy little lime cake inside a coffee mug."
	icon_state = "lime_mugcake"
	filling_color = "#51FF53"
	list_reagents = list("nutriment" = 7)

/obj/item/food/mugcake/amanita
	name = "amanita Mugcake"
	desc = "A delicious and spongy little amanita cake inside a coffee mug."
	icon_state = "amanita_mugcake"
	filling_color = "#F40909"
	list_reagents = list("nutriment" = 7, "psilocybin" = 1, "amanitin" = 1)

/obj/item/food/mugcake/honey
	name = "honey mugcake"
	desc = "A delicious and spongy little honey cake inside a coffee mug."
	icon_state = "honey_mugcake"
	list_reagents = list("nutriment" = 6)


// ---------- END of imports from Hispania!
