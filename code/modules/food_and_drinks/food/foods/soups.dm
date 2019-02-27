
//////////////////////
//		Soups		//
//////////////////////

/obj/item/reagent_containers/food/snacks/meatballsoup
	name = "meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#785210"
	bitesize = 5
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 4)

/obj/item/reagent_containers/food/snacks/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	filling_color = "#C4DBA0"
	bitesize = 5
	list_reagents = list("nutriment" = 5, "slimejelly" = 5, "water" = 5, "vitamin" = 4)

/obj/item/reagent_containers/food/snacks/bloodsoup
	name = "tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	filling_color = "#FF0000"
	bitesize = 5
	list_reagents = list("nutriment" = 2, "blood" = 10, "water" = 5, "vitamin" = 4)

/obj/item/reagent_containers/food/snacks/clownstears
	name = "clown's tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#C4FBFF"
	bitesize = 5
	list_reagents = list("nutriment" = 4, "banana" = 5, "water" = 5, "vitamin" = 8)

/obj/item/reagent_containers/food/snacks/vegetablesoup
	name = "vegetable soup"
	desc = "A true vegan meal." //TODO
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#AFC4B5"
	bitesize = 5
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 4)

/obj/item/reagent_containers/food/snacks/nettlesoup
	name = "nettle soup"
	desc = "To think, the botanist would've beaten you to death with one of these."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#AFC4B5"
	bitesize = 5
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 4)

/obj/item/reagent_containers/food/snacks/mysterysoup
	name = "mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	var/extra_reagent = null
	bitesize = 5
	list_reagents = list("nutriment" = 6)

/obj/item/reagent_containers/food/snacks/mysterysoup/New()
	..()
	extra_reagent = pick("capsaicin", "frostoil", "omnizine", "banana", "blood", "slimejelly", "toxin", "banana", "carbon", "oculine")
	reagents.add_reagent("[extra_reagent]", 5)

/obj/item/reagent_containers/food/snacks/wishsoup
	name = "Wish Soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#D1F4FF"
	bitesize = 5
	list_reagents = list("water" = 10)

/obj/item/reagent_containers/food/snacks/wishsoup/New()
	..()
	if(prob(25))
		desc = "A wish come true!" // hue
		reagents.add_reagent("nutriment", 9)
		reagents.add_reagent("vitamin", 1)

/obj/item/reagent_containers/food/snacks/tomatosoup
	name = "tomato soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#D92929"
	bitesize = 5
	list_reagents = list("nutriment" = 5, "tomatojuice" = 10, "vitamin" = 3)

/obj/item/reagent_containers/food/snacks/milosoup
	name = "milosoup"
	desc = "The universe's best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/snack_bowl
	bitesize = 5
	list_reagents = list("nutriment" = 7, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#E386BF"
	bitesize = 5
	list_reagents = list("nutriment" = 8, "vitamin" = 4)

/obj/item/reagent_containers/food/snacks/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/snack_bowl
	bitesize = 5
	filling_color = "#FAC9FF"
	list_reagents = list("nutriment" = 7, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/beetsoup/New()
	..()
	name = pick("borsch","bortsch","borstch","borsh","borshch","borscht")


//////////////////////
//		Stews		//
//////////////////////

/obj/item/reagent_containers/food/snacks/stew
	name = "stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	filling_color = "#9E673A"
	bitesize = 7
	list_reagents = list("nutriment" = 10, "oculine" = 5, "tomatojuice" = 5, "vitamin" = 5)

/obj/item/reagent_containers/food/snacks/stewedsoymeat
	name = "stewed soy meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 8)


//////////////////////
//		Chili		//
//////////////////////

/obj/item/reagent_containers/food/snacks/hotchili
	name = "hot chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FF3C00"
	bitesize = 5
	list_reagents = list("nutriment" = 5, "capsaicin" = 1, "tomatojuice" = 2, "vitamin" = 2)

/obj/item/reagent_containers/food/snacks/coldchili
	name = "cold chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2B00FF"
	trash = /obj/item/trash/snack_bowl
	bitesize = 5
	list_reagents = list("nutriment" = 5, "frostoil" = 1, "tomatojuice" = 2, "vitamin" = 2)
