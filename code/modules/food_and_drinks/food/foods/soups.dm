
//////////////////////
//		Soups		//
//////////////////////

// Base object for soups, should never appear ingame.
/obj/item/reagent_containers/food/snacks/soup
	name = "impossible soup"
	desc = "This soup is so good, it shouldn't even exist!"
	icon_state = "beans" // If you don't have a sprite, you get beans.
	consume_sound = 'sound/items/drink.ogg'
	trash = /obj/item/trash/snack_bowl
	bitesize = 5

/obj/item/reagent_containers/food/snacks/soup/meatballsoup
	name = "meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	filling_color = "#785210"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("meatball" = 1)

/obj/item/reagent_containers/food/snacks/soup/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	filling_color = "#C4DBA0"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/slimejelly = 5, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("slime" = 1)

/obj/item/reagent_containers/food/snacks/soup/bloodsoup
	name = "tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	filling_color = "#FF0000"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/blood = 10, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("iron" = 1)

/obj/item/reagent_containers/food/snacks/soup/clownstears
	name = "clown's tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#C4FBFF"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/drink/banana = 5, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 8)
	tastes = list("a bad joke" = 1)

/obj/item/reagent_containers/food/snacks/soup/vegetablesoup
	name = "vegetable soup"
	desc = "A true vegan meal." //TODO
	icon_state = "vegetablesoup"
	filling_color = "#AFC4B5"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("vegetables" = 1)

/obj/item/reagent_containers/food/snacks/soup/nettlesoup
	name = "nettle soup"
	desc = "To think, the botanist would've beaten you to death with one of these."
	icon_state = "nettlesoup"
	filling_color = "#AFC4B5"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/water = 5, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("nettles" = 1)

/obj/item/reagent_containers/food/snacks/soup/mysterysoup
	name = "mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	var/extra_reagent = null
	list_reagents = list(/datum/reagent/consumable/nutriment = 6)
	tastes = list("chaos" = 1)

/obj/item/reagent_containers/food/snacks/soup/mysterysoup/New()
	..()
	extra_reagent = pick(/datum/reagent/consumable/capsaicin, /datum/reagent/consumable/frostoil, /datum/reagent/medicine/omnizine, /datum/reagent/consumable/drink/banana,
		/datum/reagent/blood, /datum/reagent/slimejelly, /datum/reagent/toxin, /datum/reagent/consumable/drink/banana, /datum/reagent/carbon, /datum/reagent/medicine/oculine)
	reagents.add_reagent(extra_reagent, 5)

/obj/item/reagent_containers/food/snacks/soup/wishsoup
	name = "wish soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	filling_color = "#D1F4FF"
	list_reagents = list(/datum/reagent/water = 10)
	tastes = list("wishes" = 1)

/obj/item/reagent_containers/food/snacks/soup/wishsoup/New()
	..()
	if(prob(25))
		desc = "A wish come true!" // hue
		reagents.add_reagent(/datum/reagent/consumable/nutriment, 9)
		reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 1)

/obj/item/reagent_containers/food/snacks/soup/tomatosoup
	name = "tomato soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	filling_color = "#D92929"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/drink/tomatojuice = 10, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("tomato" = 1)

/obj/item/reagent_containers/food/snacks/soup/misosoup
	name = "miso soup"
	desc = "The universe's best soup! Yum!!!"
	icon_state = "misosoup"
	list_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("miso" = 1)

/obj/item/reagent_containers/food/snacks/soup/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	filling_color = "#E386BF"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("mushroom" = 1)

/obj/item/reagent_containers/food/snacks/soup/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	filling_color = "#FAC9FF"
	list_reagents = list(/datum/reagent/consumable/nutriment = 7, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("beet" = 1)

/obj/item/reagent_containers/food/snacks/soup/beetsoup/New()
	..()
	name = pick("borsch", "bortsch", "borstch", "borsh", "borshch", "borscht")


//////////////////////
//		Stews		//
//////////////////////

/obj/item/reagent_containers/food/snacks/soup/stew
	name = "stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	filling_color = "#9E673A"
	bitesize = 7
	list_reagents = list(/datum/reagent/consumable/nutriment = 10, /datum/reagent/medicine/oculine = 5, /datum/reagent/consumable/drink/tomatojuice = 5, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("tomato" = 1, "carrot" = 1)

/obj/item/reagent_containers/food/snacks/stewedsoymeat
	name = "stewed soy meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("soy" = 1, "vegetables" = 1)


//////////////////////
//		Chili		//
//////////////////////

/obj/item/reagent_containers/food/snacks/soup/hotchili
	name = "hot chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	filling_color = "#FF3C00"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/drink/tomatojuice = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("hot peppers" = 1, "tomato" = 1)

/obj/item/reagent_containers/food/snacks/soup/coldchili
	name = "cold chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2B00FF"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/frostoil = 1, /datum/reagent/consumable/drink/tomatojuice = 2, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("tomato" = 1, "mint" = 1)
