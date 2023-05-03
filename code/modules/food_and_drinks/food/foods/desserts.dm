
//////////////////////
//	Ice Cream		//
//////////////////////

/obj/item/reagent_containers/food/snacks/icecream
	name = "ice cream"
	desc = "Delicious ice cream."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_cone"
	bitesize = 3
	list_reagents = list("nutriment" = 1, "sugar" = 1)
	tastes = list("ice cream" = 1)
	foodtype = SUGAR | DAIRY

/obj/item/reagent_containers/food/snacks/icecream/update_icon()
	cut_overlays()
	var/mutable_appearance/filling = mutable_appearance('icons/obj/kitchen.dmi', "icecream_color")
	filling.color = mix_color_from_reagents(reagents.reagent_list)
	add_overlay(filling)

/obj/item/reagent_containers/food/snacks/icecream/icecreamcone
	name = "ice cream cone"
	desc = "Delicious ice cream."
	icon_state = "icecream_cone"
	volume = 50
	bitesize = 3
	list_reagents = list("nutriment" = 3, "sugar" = 7, "ice" = 2)

/obj/item/reagent_containers/food/snacks/icecream/icecreamcup
	name = "chocolate ice cream cone"
	desc = "Delicious ice cream."
	icon_state = "icecream_cup"
	volume = 50
	bitesize = 6
	list_reagents = list("nutriment" = 5, "chocolate" = 8, "ice" = 2)

/obj/item/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in its own packaging."
	icon_state = "icecreamsandwich"
	list_reagents = list("nutriment" = 2, "ice" = 2)
	foodtype = SUGAR | DAIRY


//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/friedbanana
	name = "fried banana"
	desc = "Goreng Pisang, also known as fried bananas."
	icon_state = "friedbanana"
	list_reagents = list("sugar" = 5, "nutriment" = 8, "cornoil" = 4)
	foodtype = FRIED | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/ricepudding
	name = "rice pudding"
	desc = "Where's the Jam!"
	icon_state = "rpudding"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FFFBDB"
	list_reagents = list("nutriment" = 7, "vitamin" = 2)
	tastes = list("rice" = 1, "sweetness" = 1)
	foodtype = GRAIN | SUGAR

/obj/item/reagent_containers/food/snacks/spacylibertyduff
	name = "spacy liberty duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#42B873"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "psilocybin" = 6)
	tastes = list("jelly" = 1, "mushroom" = 1)
	foodtype = FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/amanitajelly
	name = "amanita jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ED0758"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "amanitin" = 6, "psilocybin" = 3)
	tastes = list("jelly" = 1, "mushroom" = 1)
	foodtype = VEGETABLES | SUGAR
	log_eating = TRUE

/obj/item/reagent_containers/food/snacks/candiedapple
	name = "candied apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	filling_color = "#F21873"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "sugar" = 2)
	tastes = list("apple" = 2, "sweetness" = 2)
	foodtype = FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon_state = "mint"
	bitesize = 1
	filling_color = "#F2F2F2"
	list_reagents = list("minttoxin" = 1)
