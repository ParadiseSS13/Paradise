
//////////////////////
//	Raw Pasta		//
//////////////////////

/obj/item/food/snacks/spaghetti
	name = "spaghetti"
	desc = "A bundle of raw spaghetti."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "spaghetti"
	filling_color = "#EDDD00"
	list_reagents = list("nutriment" = 1, "vitamin" = 1)
	tastes = list("raw pasta" = 1)
	foodtypes = GRAIN

/obj/item/food/snacks/macaroni
	name = "macaroni twists"
	desc = "These are little twists of raw macaroni."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "macaroni"
	filling_color = "#EDDD00"
	list_reagents = list("nutriment" = 1, "vitamin" = 1)
	tastes = list("raw pasta" = 1)
	foodtypes = GRAIN

//////////////////////
//	Pasta Dishes	//
//////////////////////

/obj/item/food/snacks/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles. This sucks."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "spaghettiboiled"
	trash = /obj/item/trash/plate
	filling_color = "#FCEE81"
	list_reagents = list("nutriment" = 2, "vitamin" = 1)
	tastes = list("pasta" = 1)
	quality = FOOD_QUALITY_GOOD
	foodtypes = GRAIN
/obj/item/food/snacks/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	filling_color = "#DE4545"
	bitesize = 4
	list_reagents = list("nutriment" = 6, "tomatojuice" = 10, "vitamin" = 4)
	tastes = list("pasta" = 1, "tomato" = 1)
	quality = FOOD_QUALITY_GOOD
	foodtypes = GRAIN | VEGETABLES_AND_FRUITS
/obj/item/food/snacks/meatballspaghetti
	name = "spaghetti & meatballs"
	desc = "Now that's a nice'a meatball!"
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "meatballspaghetti"
	trash = /obj/item/trash/plate
	filling_color = "#DE4545"
	list_reagents = list("nutriment" = 8, "synaptizine" = 5, "vitamin" = 4)
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 1)
	quality = FOOD_QUALITY_GOOD
	foodtypes = GRAIN | MEAT | VEGETABLES_AND_FRUITS
/obj/item/food/snacks/spesslaw
	name = "spesslaw"
	desc = "A lawyer's favourite."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "spesslaw"
	filling_color = "#DE4545"
	list_reagents = list("nutriment" = 8, "synaptizine" = 10, "vitamin" = 6)
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 2)
	quality = FOOD_QUALITY_GOOD
	foodtypes = GRAIN | MEAT | VEGETABLES_AND_FRUITS
/obj/item/food/snacks/macncheese
	name = "mac 'n' cheese"
	desc = "One of the most comforting foods in the world. Apparently."
	trash = /obj/item/trash/snack_bowl
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "macncheese"
	filling_color = "#ffe45d"
	list_reagents = list("nutriment" = 5, "vitamin" = 2, "cheese" = 4)
	tastes = list("pasta" = 1, "cheese" = 1, "comfort" = 1)
	quality = FOOD_QUALITY_GOOD
	foodtypes = GRAIN | DAIRY
/obj/item/food/snacks/lasagna
	name = "lasagna"
	desc = "Tajara love to eat this, for some reason."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "lasagna"
	filling_color = "#E18712"
	list_reagents = list("nutriment" = 10, "msg" = 3, "vitamin" = 4, "tomatojuice" = 10)
	tastes = list("pasta" = 1, "cheese" = 1, "tomato" = 1, "meat" = 1)
	quality = FOOD_QUALITY_VERYGOOD
	foodtypes = GRAIN | DAIRY | MEAT
