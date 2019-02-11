
//////////////////////
//	Tofu & Soy		//
//////////////////////

/obj/item/reagent_containers/food/snacks/tofu
	name = "tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("plantmatter" = 2)

/obj/item/reagent_containers/food/snacks/fried_tofu
	name = "fried tofu"
	icon_state = "tofu"
	desc = "Proof that even vegetarians crave unhealthy foods."
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("plantmatter" = 3)

/obj/item/reagent_containers/food/snacks/soydope
	name = "soy dope"
	desc = "Like regular dope, but for the health concious consumer."
	icon_state = "soydope"
	trash = /obj/item/trash/plate
	filling_color = "#C4BF76"
	list_reagents = list("nutriment" = 2)


//////////////////////
//		Cheese		//
//////////////////////

/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
	name = "cheese wheel"
	desc = "A big wheel of delicious Cheddar."
	icon_state = "cheesewheel"
	slice_path = /obj/item/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	filling_color = "#FFF700"
	list_reagents = list("nutriment" = 15, "vitamin" = 5, "cheese" = 20)

/obj/item/reagent_containers/food/snacks/cheesewedge
	name = "cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#FFF700"

/obj/item/reagent_containers/food/snacks/weirdcheesewedge
	name = "weird cheese"
	desc = "Some kind of... gooey, messy, gloopy thing. Similar to cheese, but only in the broad sense of the word."
	icon_state = "weirdcheesewedge"
	filling_color = "#00FF33"
	list_reagents = list("mercury" = 5, "lsd" = 5, "ethanol" = 5, "weird_cheese" = 5)


//////////////////////
//		Plants		//
//////////////////////

/obj/item/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#E0D7C5"
	bitesize = 6
	list_reagents = list("plantmatter" = 3, "vitamin" = 1)

/obj/item/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"
	filling_color = "#DB0000"
	bitesize = 6
	list_reagents = list("protein" = 2)

/obj/item/reagent_containers/food/snacks/watermelonslice
	name = "watermelon slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	filling_color = "#FF3867"

/obj/item/reagent_containers/food/snacks/pineappleslice
	name = "pineapple slices"
	desc = "Rings of pineapple."
	icon_state = "pineappleslice"
	filling_color = "#e5b437"


//////////////////////
//		Dough		//
//////////////////////

/obj/item/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "dough"
	list_reagents = list("nutriment" = 6)

// Dough + rolling pin = flat dough
/obj/item/reagent_containers/food/snacks/dough/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/reagent_containers/food/snacks/sliceable/flatdough(loc)
			to_chat(user, "<span class='notice'>You flatten [src].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to roll it out!</span>")
	else
		..()

// slicable into 3xdoughslices
/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "Some flattened dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/reagent_containers/food/snacks/doughslice
	slices_num = 3
	list_reagents = list("nutriment" = 6)

/obj/item/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "The building block of an impressive dish."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "doughslice"
	list_reagents = list("nutriment" = 1)


//////////////////////
//	Chocolate		//
//////////////////////

/obj/item/reagent_containers/food/snacks/chocolatebar
	name = "chocolate bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 2, "sugar" = 2, "cocoa" = 2)

/obj/item/reagent_containers/food/snacks/choc_pile //for reagent chocolate being spilled on turfs
	name = "pile of chocolate"
	desc = "A pile of pure chocolate pieces."
	icon_state = "cocoa"
	filling_color = "#7D5F46"
	list_reagents = list("chocolate" = 5)


//////////////////////
//		Misc		//
//////////////////////

/obj/item/reagent_containers/food/snacks/ectoplasm
	name = "ectoplasm"
	desc = "A luminescent blob of what scientists refer to as 'ghost goo'."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"
	list_reagents = list("ectoplasm" = 10)
