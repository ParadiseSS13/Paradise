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

////////////////////////
// 		Hispania!		//
////////////////////////

/obj/item/food/mousse_avocado
	name = "Avocado Chocolate Mousse"
	desc = "A mousse made of avocado and cacao."
	icon_state = "mousse_avocado"
	bitesize = 1
	trash = /obj/item/trash/empty_plasticcup
	list_reagents = list("nutriment" = 1, "chocolate" = 4, "cream" = 3)
	filling_color = "#462B00"
	tastes = list("quality chocolate" = 1)

// ---------- END of imports from Hispania!
