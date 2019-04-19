
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

/obj/item/reagent_containers/food/snacks/macaroni
	name = "macaroni twists"
	desc = "These are little twists of raw macaroni."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "macaroni"
	filling_color = "#EDDD00"
	list_reagents = list("nutriment" = 1, "vitamin" = 1)


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

/obj/item/reagent_containers/food/snacks/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	filling_color = "#DE4545"
	bitesize = 4
	list_reagents = list("nutriment" = 6, "tomatojuice" = 10, "vitamin" = 4)

/obj/item/reagent_containers/food/snacks/meatballspaghetti
	name = "spaghetti & meatballs"
	desc = "Now thats a nice'a meatball!"
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "meatballspaghetti"
	trash = /obj/item/trash/plate
	filling_color = "#DE4545"
	list_reagents = list("nutriment" = 8, "synaptizine" = 5, "vitamin" = 4)

/obj/item/reagent_containers/food/snacks/spesslaw
	name = "Spesslaw"
	desc = "A lawyer's favourite."
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "spesslaw"
	filling_color = "#DE4545"
	list_reagents = list("nutriment" = 8, "synaptizine" = 10, "vitamin" = 6)

/obj/item/reagent_containers/food/snacks/macncheese
	name = "mac n cheese"
	desc = "One of the most comforting foods in the world. Apparently."
	trash = /obj/item/trash/snack_bowl
	icon = 'icons/obj/food/pasta.dmi'
	icon_state = "macncheese"
	filling_color = "#ffe45d"
	list_reagents = list("nutriment" = 5, "vitamin" = 2, "cheese" = 4)
