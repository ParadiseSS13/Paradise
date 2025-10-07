
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
	slice_path = /obj/item/food/sliced/cheesewedge
	slices_num = 5
	filling_color = "#FFF700"
	list_reagents = list("nutriment" = 16, "vitamin" = 4, "cheese" = 20)
	tastes = list("cheese" = 1)

/obj/item/food/sliced/cheesewedge
	name = "cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#FFF700"
	list_reagents = list("nutriment" = 4, "vitamin" = 1, "cheese" = 5)
	tastes = list("cheese" = 1)

/obj/item/food/sliceable/cheesewheel/smoked
	name = "smoked cheese wheel"
	desc = "A wheel of fancy imported-style smoked cheese."
	icon_state = "cheesewheel-smoked"
	slice_path = /obj/item/food/sliced/cheesewedge/smoked
	slices_num = 4
	list_reagents = list("nutriment" = 16, "vitamin" = 4, "cheese" = 20)
	tastes = list("cheese" = 1, "smoke" = 2)

/obj/item/food/sliced/cheesewedge/smoked
	name = "smoked cheese wedge"
	desc = "A wedge of fancy smoked cheese."
	icon_state = "cheesewedge-smoked"
	list_reagents = list("nutriment" = 4, "vitamin" = 1, "cheese" = 5)
	tastes = list("cheese" = 1, "smoke" = 2)

/obj/item/food/sliceable/cheesewheel/edam
	name = "edam cheese wheel"
	desc = "A wheel of mild edam cheese."
	icon_state = "cheesewheel-edam"
	slice_path = /obj/item/food/sliced/cheesewedge/edam
	slices_num = 4
	list_reagents = list("nutriment" = 16, "vitamin" = 4, "cheese" = 20)
	tastes = list("cheese" = 1, "salt" = 2, "almonds" = 2)

/obj/item/food/sliced/cheesewedge/edam
	name = "edam cheese wedge"
	desc = "A wedge of mild edam cheese. It's said to have a nutty flavor."
	icon_state = "cheesewedge-edam"
	list_reagents = list("nutriment" = 4, "vitamin" = 1, "cheese" = 5)
	tastes = list("cheese" = 1, "salt" = 2, "almonds" = 2)

/obj/item/food/sliceable/cheesewheel/blue
	name = "blue cheese wheel"
	desc = "A wheel of pungent blue cheese. It's an acquired taste..."
	icon_state = "cheesewheel-blue"
	slice_path = /obj/item/food/sliced/cheesewedge/blue
	slices_num = 4
	list_reagents = list("nutriment" = 4, "vitamin" = 4, "cheese" = 12)
	tastes = list("strong cheese" = 2, "salt" = 1, "bitter mold" = 1)

/obj/item/food/sliced/cheesewedge/blue
	name = "blue cheese wedge"
	desc = "A wedge of pungent blue cheese. The flavor is... intense."
	icon_state = "cheesewedge-blue"
	list_reagents = list("nutriment" = 1, "vitamin" = 1, "cheese" = 3)
	tastes = list("strong cheese" = 2, "salt" = 1, "bitter mold" = 1)

/obj/item/food/sliceable/cheesewheel/camembert
	name = "camembert cheese wheel"
	desc = "A miniature wheel of gooey camembert. Yum..."
	icon_state = "cheesewheel-camembert"
	slice_path = /obj/item/food/sliced/cheesewedge/camembert
	slices_num = 2
	list_reagents = list("nutriment" = 4, "vitamin" = 4, "cheese" = 8)
	tastes = list("mild cheese" = 3, "gooeyness" = 1)

/obj/item/food/sliced/cheesewedge/camembert
	name = "camembert cheese slice"
	desc = "A piece of camembert. It's soft and gooey."
	icon_state = "cheesewedge-camembert"
	list_reagents = list("nutriment" = 2, "vitamin" = 2, "cheese" = 4)
	tastes = list("mild cheese" = 3, "gooeyness" = 1)

/obj/item/food/sliced/cheesewedge/checkpass(passflag)
	if((passflag & PASSDOOR) && ismouse(pulledby))
		return TRUE
	return ..()

/obj/item/food/weirdcheesewedge
	name = "weird cheese"
	desc = "Some kind of... gooey, messy, gloopy thing. Similar to cheese, but only in the broad sense of the word."
	icon_state = "weirdcheesewedge"
	filling_color = "#00FF33"
	list_reagents = list("mercury" = 5, "lsd" = 5, "ethanol" = 5, "weird_cheese" = 5)

/obj/item/food/cheese_curds
	name = "cheese curds"
	desc = "Known by many names throughout human cuisine, curd cheese is useful for a wide variety of dishes."
	icon_state = "cheese_curds"
	filling_color = "#FFF700"
	list_reagents = list("cheese_curds" = 4, "nutriment" = 3, "vitamin" = 1)

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

/obj/item/food/sliced/watermelon
	name = "watermelon slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice" // Sprite created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	filling_color = "#FF3867"
	list_reagents = list("plantmatter" = 1)
	tastes = list("watermelon" = 1)

/obj/item/food/sliced/tomato
	name = "tomato slice"
	desc = "A fresh slice of tomato."
	icon_state = "tomatoslice"
	filling_color = "#DB0000"
	list_reagents = list("plantmatter" = 2)
	tastes = list("tomato" = 1)

/obj/item/food/sliced/pineapple
	name = "pineapple slices"
	desc = "Rings of pineapple."
	icon_state = "pineappleslice" // Sprite created by https://github.com/binarysudoku for Goonstation, They have relicensed it for our use.
	filling_color = "#e5b437"
	list_reagents = list("plantmatter" = 1, "vitamin" = 1)
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
/obj/item/food/dough/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/kitchen/rollingpin))
		return NONE

	if(isturf(loc))
		new /obj/item/food/sliceable/flatdough(loc)
		to_chat(user, "<span class='notice'>You flatten [src].</span>")
		qdel(src)
	else
		to_chat(user, "<span class='notice'>You need to put [src] on a surface to roll it out!</span>")
	return ITEM_INTERACT_COMPLETE

// slicable into 3xdoughslices
/obj/item/food/sliceable/flatdough
	name = "flat dough"
	desc = "Some flattened dough."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/food/sliced/dough
	slices_num = 3
	list_reagents = list("nutriment" = 6)
	tastes = list("dough" = 1)


/obj/item/food/sliced/dough
	name = "dough slice"
	desc = "The building block of an impressive dish."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "doughslice"
	list_reagents = list("nutriment" = 2)
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
/obj/item/food/cookiedough/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/kitchen/rollingpin))
		if(flat)
			to_chat(user, "<span class='warning'>[src] doesn't need to be flattened any further!</span>")
			return ITEM_INTERACT_COMPLETE

		if(isturf(loc))
			to_chat(user, "<span class='notice'>You flatten [src].</span>")
			flat = TRUE
			update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a surface to roll it out!</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/kitchen/cutter))
		if(!flat)
			to_chat(user, "<span class='warning'>[src] needs to be flattened first!</span>")
			return ITEM_INTERACT_COMPLETE

		if(isturf(loc))
			new /obj/item/food/rawcookies(loc)
			to_chat(user, "<span class='notice'>You cut [src] into cookies.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a surface to cut it out!</span>")
		return ITEM_INTERACT_COMPLETE

	return NONE


/obj/item/food/rawcookies
	name = "raw cookies"
	desc = "Ready for oven!"
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "unbaked_cookies"
	list_reagents = list("nutriment" = 5, "sugar" = 5)

/obj/item/food/rawcookies/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/food/choc_pile))
		if(isturf(loc))
			new /obj/item/food/rawcookies/chocochips(loc)
			to_chat(user, "<span class='notice'>You sprinkle [used] all over the cookies.</span>")
			qdel(src)
			qdel(used)
		else
			to_chat(user, "<span class='warning'>You need to put [src] on a surface to add [used]!</span>")
		return ITEM_INTERACT_COMPLETE

	return NONE
	

/obj/item/food/rawcookies/chocochips
	desc = "Ready for oven! They have little pieces of chocolate all over them"
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
/obj/item/food/chocolatebar/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/kitchen/knife))
		return NONE

	if(isturf(loc))
		new /obj/item/food/choc_pile(loc)
		to_chat(user, "<span class='notice'>You cut [src] into little crumbles.</span>")
		qdel(src)
	else
		to_chat(user, "<span class='warning'>You need to put [src] on a surface to cut it out!</span>")
	return ITEM_INTERACT_COMPLETE


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
	tastes = list("spookiness" = 2, "salt" = 2) // Ghosts are in fact salty.
