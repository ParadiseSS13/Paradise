
//////////////////////
//	Raw Pasta		//
//////////////////////

/obj/item/reagent_containers/food/snacks/spaghetti
	name = "spaghetti"
	desc = "A bundle of raw spaghetti."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "spaghetti"
	filling_color = "#EDDD00"
	list_reagents = list("nutriment" = 1, "vitamin" = 1)
	tastes = list("raw pasta" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/macaroni
	name = "macaroni twists"
	desc = "These are little twists of raw macaroni."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "macaroni"
	filling_color = "#EDDD00"
	list_reagents = list("nutriment" = 1, "vitamin" = 1)
	tastes = list("raw pasta" = 1)
	foodtype = GRAIN


//////////////////////
//	Pasta Dishes	//
//////////////////////

/obj/item/reagent_containers/food/snacks/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles. This sucks."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "spaghettiboiled"
	trash = /obj/item/trash/plate
	filling_color = "#FCEE81"
	list_reagents = list("nutriment" = 2, "vitamin" = 1)
	tastes = list("pasta" = 1)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	filling_color = "#DE4545"
	bitesize = 4
	list_reagents = list("nutriment" = 6, "tomatojuice" = 10, "vitamin" = 4)
	tastes = list("pasta" = 1, "tomato" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/meatballspaghetti
	name = "spaghetti & meatballs"
	desc = "Now thats a nice'a meatball!"
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "meatballspaghetti"
	trash = /obj/item/trash/plate
	filling_color = "#DE4545"
	list_reagents = list("nutriment" = 8, "synaptizine" = 5, "vitamin" = 4)
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/spesslaw
	name = "spesslaw"
	desc = "A lawyer's favourite."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "spesslaw"
	filling_color = "#DE4545"
	list_reagents = list("nutriment" = 8, "synaptizine" = 10, "vitamin" = 6)
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 2)
	foodtype = GRAIN | MEAT


/obj/item/reagent_containers/food/snacks/macncheese
	name = "mac 'n' cheese"
	desc = "One of the most comforting foods in the world. Apparently."
	trash = /obj/item/trash/snack_bowl
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "macncheese"
	filling_color = "#ffe45d"
	list_reagents = list("nutriment" = 5, "vitamin" = 2, "cheese" = 4)
	tastes = list("pasta" = 1, "cheese" = 1, "comfort" = 1)
	foodtype = GRAIN | DAIRY

/obj/item/reagent_containers/food/snacks/lasagna
	name = "Lasagna"
	desc = "Tajara are supposed to love to eat this, but the tomato really doesn't work well."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "lasagna"
	filling_color = "#E18712"
	list_reagents = list("nutriment" = 10, "msg" = 3, "vitamin" = 4, "tomatojuice" = 10)
	tastes = list("pasta" = 1, "cheese" = 1, "tomato" = 1, "meat" = 1)
	foodtype = GRAIN | DAIRY | VEGETABLES | MEAT

/obj/item/reagent_containers/food/snacks/chowmein
	name = "Chowmein"
	desc = "Nihao!"
	icon_state = "chowmein"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 6, "protein" = 6)
	tastes = list("pasta" = 1, "carrot" = 1, "cabage" = 1, "meat" = 1)
	bitesize = 3
	foodtype = GRAIN | VEGETABLES | MEAT

/obj/item/reagent_containers/food/snacks/beefnoodles
	name = "Beef noodles"
	desc = "So simple, but so yummy!"
	icon_state = "beefnoodles"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 3, "protein" = 5, "plantmatter" = 3)
	tastes = list("pasta" = 1, "cabage" = 1, "meat" = 2)
	bitesize = 2
	foodtype = GRAIN | VEGETABLES | MEAT
