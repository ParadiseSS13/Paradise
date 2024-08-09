
//////////////////////
//	Tofu & Soy		//
//////////////////////

/obj/item/food/tofu
	name = "tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("plantmatter" = 2)
	tastes = list("tofu" = 1)
	ingredient_name = "tofu chunk"

/obj/item/food/fried_tofu
	name = "fried tofu"
	icon_state = "tofu"
	desc = "Proof that even vegetarians crave unhealthy foods."
	filling_color = "#FFFEE0"
	bitesize = 3
	list_reagents = list("plantmatter" = 3)
	tastes = list("tofu" = 1)
	goal_difficulty = FOOD_GOAL_NORMAL

/obj/item/food/soydope
	name = "soy dope"
	icon_state = "soydope"
	desc = "Like regular dope, but for the health conscious consumer."
	trash = /obj/item/trash/plate
	filling_color = "#C4BF76"
	list_reagents = list("nutriment" = 2)
	tastes = list("soy" = 1)


//////////////////////
//		Cheese		//
//////////////////////

/obj/item/food/sliceable/cheesewheel
	name = "cheese wheel"
	desc = "A big wheel of delicious Cheddar."
	icon_state = "cheesewheel"
	slice_path = /obj/item/food/cheesewedge
	slices_num = 5
	filling_color = "#FFF700"
	list_reagents = list("nutriment" = 15, "vitamin" = 5, "cheese" = 20)
	tastes = list("cheese" = 1)

/obj/item/food/cheesewedge
	name = "cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#FFF700"
	tastes = list("cheese" = 1)

/obj/item/food/cheesewedge/checkpass(passflag)
	if((passflag & PASSDOOR) && ismouse(pulledby))
		return TRUE
	return ..()

/obj/item/food/cheesewedge/presliced
	list_reagents = list("nutriment" = 3, "vitamin" = 1, "cheese" = 4)

/obj/item/food/weirdcheesewedge
	name = "weird cheese"
	desc = "Some kind of... gooey, messy, gloopy thing. Similar to cheese, but only in the broad sense of the word."
	icon_state = "weirdcheesewedge"
	filling_color = "#00FF33"
	list_reagents = list("mercury" = 5, "lsd" = 5, "ethanol" = 5, "weird_cheese" = 5)


//////////////////////
//		Plants		//
//////////////////////

/obj/item/food/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#E0D7C5"
	bitesize = 6
	list_reagents = list("plantmatter" = 3, "vitamin" = 1)
	tastes = list("mushroom" = 1)

/obj/item/food/watermelonslice
	name = "watermelon slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice" // Sprite created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	filling_color = "#FF3867"
	tastes = list("watermelon" = 1)

/obj/item/food/tomatoslice
	name = "tomato slice"
	desc = "A fresh slice of tomato."
	icon_state = "tomatoslice"
	filling_color = "#DB0000"
	list_reagents = list("plantmatter" = 2)
	tastes = list("tomato" = 1)

/obj/item/food/pineappleslice
	name = "pineapple slices"
	desc = "Rings of pineapple."
	icon_state = "pineappleslice" // Sprite created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	filling_color = "#e5b437"
	tastes = list("pineapple" = 1)


//////////////////////
//		Dough		//
//////////////////////

/obj/item/food/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "dough"
	list_reagents = list("nutriment" = 6)
	tastes = list("dough" = 1)

// Dough + rolling pin = flat dough
/obj/item/food/dough/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/rollingpin))
		if(isturf(loc))
			new /obj/item/food/sliceable/flatdough(loc)
			to_chat(user, "<span class='notice'>You flatten [src].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to roll it out!</span>")
	else
		..()

// slicable into 3xdoughslices
/obj/item/food/sliceable/flatdough
	name = "flat dough"
	desc = "Some flattened dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/food/doughslice
	slices_num = 3
	list_reagents = list("nutriment" = 6)
	tastes = list("dough" = 1)


/obj/item/food/doughslice
	name = "dough slice"
	desc = "The building block of an impressive dish."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "doughslice"
	list_reagents = list("nutriment" = 1)
	tastes = list("dough" = 1)


///cookies by Ume

/obj/item/food/cookiedough
	var/flat = FALSE
	name = "pastry dough"
	icon = 'icons/obj/food/food_ingredients.dmi'
	desc = "The base for tasty cookies."
	icon_state = "cookiedough"
	list_reagents = list("nutriment" = 5, "sugar" = 5)
	tastes = list("dough" = 1, "sugar" = 1)

/obj/item/food/cookiedough/update_name()
	. = ..()
	if(flat)
		name = "flat pastry dough"

/obj/item/food/cookiedough/update_icon_state()
	if(flat)
		icon_state = "cookiedough_flat"
	else
		icon_state = "cookiedough"

// Dough + rolling pin = flat cookie dough // Flat dough + circular cutter = unbaked cookies
/obj/item/food/cookiedough/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/rollingpin) && !flat)
		if(isturf(loc))
			to_chat(user, "<span class='notice'>You flatten [src].</span>")
			flat = TRUE
			update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to roll it out!</span>")
	else if(istype(I, /obj/item/kitchen/cutter) && flat)
		if(isturf(loc))
			new /obj/item/food/rawcookies(loc)
			to_chat(user, "<span class='notice'>You cut [src] into cookies.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to cut it out!</span>")
	else
		return ..()


/obj/item/food/rawcookies
	name = "raw cookies"
	desc = "Ready for oven!"
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "unbaked_cookies"
	list_reagents = list("nutriment" = 5, "sugar" = 5)

/obj/item/food/rawcookies/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/food/choc_pile))
		if(isturf(loc))
			new /obj/item/food/rawcookies/chocochips(loc)
			to_chat(user, "<span class='notice'>You sprinkle [I] all over the cookies.</span>")
			qdel(src)
			qdel(I)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to add this</span>")
	else
		return ..()

/obj/item/food/rawcookies/chocochips
	name = "raw cookies"
	desc = "Ready for oven! They have little pieces of chocolate all over them"
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "unbaked_cookies_choco"
	list_reagents = list("nutriment" = 5, "sugar" = 5, "chocolate" = 5)
	tastes = list("dough" = 1, "sugar" = 1, "chocolate" = 1)

//////////////////////
//	Chocolate		//
//////////////////////

/obj/item/food/chocolatebar
	name = "chocolate bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7D5F46"
	list_reagents = list("nutriment" = 2, "sugar" = 2, "cocoa" = 2)
	tastes = list("chocolate" = 1)
	goal_difficulty = FOOD_GOAL_EASY

///Chocolate crumbles/pile
/obj/item/food/chocolatebar/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/kitchen/knife))
		if(isturf(loc))
			new /obj/item/food/choc_pile(loc)
			to_chat(user, "<span class='notice'>You cut [src] into little crumbles.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You need to put [src] on a surface to cut it out!</span>")
	else
		return ..()


/// for reagent chocolate being spilled on turfs
/obj/item/food/choc_pile
	name = "pile of chocolate"
	desc = "A pile of pure chocolate pieces."
	icon_state = "cocoa"
	filling_color = "#7D5F46"
	list_reagents = list("chocolate" = 5)
	tastes = list("chocolate" = 1)


//////////////////////
//		Misc		//
//////////////////////

/obj/item/food/ectoplasm
	name = "ectoplasm"
	desc = "A luminescent blob of what scientists refer to as 'ghost goo'."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"
	list_reagents = list("ectoplasm" = 10)
	tastes = list("spookiness" = 1)
