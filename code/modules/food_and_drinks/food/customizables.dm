#define MAKE_CUSTOM_FOOD(snack_to_add, user, type) \
do {\
	var/obj/item/food/customizable/custom_snack = new type(get_turf(user));\
	custom_snack.add_ingredient(snack_to_add, user); \
	user.put_in_active_hand(custom_snack); \
	qdel(src);\
} while(FALSE)

/obj/item/food/sliced/bread/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/food) && !(used.flags & NODROP))
		MAKE_CUSTOM_FOOD(used, user, /obj/item/food/customizable/sandwich)
		return ITEM_INTERACT_COMPLETE
	..()

/obj/item/food/bun/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/food) && !(used.flags & NODROP))
		MAKE_CUSTOM_FOOD(used, user, /obj/item/food/customizable/burger)
		return ITEM_INTERACT_COMPLETE
	..()

/obj/item/food/sliceable/flatdough/item_interaction(mob/living/user, obj/item/used, list/modifiers)

	if(istype(used, /obj/item/food) && !(used.flags & NODROP))
		MAKE_CUSTOM_FOOD(used, user, /obj/item/food/customizable/pizza)
		return ITEM_INTERACT_COMPLETE
	..()

/obj/item/food/boiledspaghetti/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/food) && !(used.flags & NODROP))
		MAKE_CUSTOM_FOOD(used, user, /obj/item/food/customizable/pasta)
		return ITEM_INTERACT_COMPLETE
	..()

/obj/item/trash/plate/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/food) && !(W.flags & NODROP))
		MAKE_CUSTOM_FOOD(W, user, /obj/item/food/customizable/fullycustom)
		return
	..()

#undef MAKE_CUSTOM_FOOD

/obj/item/trash/bowl
	name = "bowl"
	desc = "An empty bowl. Put some food in it to start making a soup."
	icon = 'icons/obj/food/custom.dmi'
	icon_state = "soup"

/obj/item/trash/bowl/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/food) && !(I.flags & NODROP))
		var/obj/item/food/customizable/soup/S = new(get_turf(user))
		S.item_interaction(I, user, params)
		qdel(src)
	else
		..()

/obj/item/food/customizable
	name = "sandwich"
	desc = "A sandwich! A timeless classic."
	icon = 'icons/obj/food/custom.dmi'
	icon_state = "sandwichcustom"
	var/baseicon = "sandwichcustom"
	var/basename = "sandwichcustom"
	bitesize = 4
	/// Do we have a top?
	var/top = TRUE
	/// The image of the top
	var/image/top_image
	var/snack_overlays = 1	//Do we stack?
//	var/offsetstuff = 1 //Do we offset the overlays?
	var/ingredient_limit = 40
	var/fullycustom = 0
	trash = /obj/item/trash/plate
	var/list/ingredients = list()
	list_reagents = list("nutriment" = 8)

/obj/item/food/customizable/Initialize(mapload)
	. = ..()
	if(top)
		top_image = new(icon, "[baseicon]_top")
		add_overlay(top_image)

/obj/item/food/customizable/sandwich
	basename = "sandwich"

/obj/item/food/customizable/pizza
	name = "personal pizza"
	desc = "A personalized pan pizza meant for only one person."
	icon_state = "personal_pizza"
	baseicon = "personal_pizza"
	basename = "personal pizza"
	snack_overlays = 0
	top = 0
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)

/obj/item/food/customizable/pasta
	name = "spaghetti"
	desc = "Noodles. With stuff. Delicious."
	icon_state = "pasta_bot"
	baseicon = "pasta_bot"
	basename = "pasta"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/cook/bread
	name = "bread"
	desc = "Tasty bread."
	icon_state = "breadcustom"
	baseicon = "breadcustom"
	basename = "bread"
	snack_overlays = 0
	top = 0
	tastes = list("bread" = 10)

/obj/item/food/customizable/cook/pie
	name = "pie"
	desc = "Tasty pie."
	icon_state = "piecustom"
	baseicon = "piecustom"
	basename = "pie"
	snack_overlays = 0
	top = 0
	tastes = list("pie" = 1)

/obj/item/food/customizable/cook/cake
	name = "cake"
	desc = "A popular band."
	icon_state = "cakecustom"
	baseicon = "cakecustom"
	basename = "cake"
	snack_overlays = 0
	top = 0
	tastes = list("cake" = 1)

/obj/item/food/customizable/cook/jelly
	name = "jelly"
	desc = "Totally jelly."
	icon_state = "jellycustom"
	baseicon = "jellycustom"
	basename = "jelly"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/cook/donkpocket
	name = "donk pocket"
	desc = "You wanna put a bangin- Oh, never mind."
	icon_state = "donkcustom"
	baseicon = "donkcustom"
	basename = "donk pocket"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/cook/kebab
	name = "kebab"
	desc = "Kebab or Kabab?"
	icon_state = "kababcustom"
	baseicon = "kababcustom"
	basename = "kebab"
	snack_overlays = 0
	top = 0
	tastes = list("meat" = 3, "metal" = 1)

/obj/item/food/customizable/cook/salad
	name = "salad"
	desc = "Very tasty."
	icon_state = "saladcustom"
	baseicon = "saladcustom"
	basename = "salad"
	snack_overlays = 0
	top = 0
	tastes = list("leaves" = 1)

/obj/item/food/customizable/cook/waffles
	name = "waffles"
	desc = "Made with love."
	icon_state = "wafflecustom"
	baseicon = "wafflecustom"
	basename = "waffles"
	snack_overlays = 0
	top = 0
	tastes = list("waffles" = 1)

/obj/item/food/customizable/candy/cookie
	name = "cookie"
	desc = "COOKIE!!1!"
	icon_state = "cookiecustom"
	baseicon = "cookiecustom"
	basename = "cookie"
	snack_overlays = 0
	top = 0
	tastes = list("cookie" = 1)

/obj/item/food/customizable/candy/cotton
	name = "flavored cotton candy"
	desc = "Who can take a sunrise, sprinkle it with dew."
	icon_state = "cottoncandycustom"
	baseicon = "cottoncandycustom"
	basename = "flavored cotton candy"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/candy/gummybear
	name = "flavored giant gummy bear"
	desc = "Cover it in chocolate and a miracle or two."
	icon_state = "gummybearcustom"
	baseicon = "gummybearcustom"
	basename = "flavored giant gummy bear"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/candy/gummyworm
	name = "flavored giant gummy worm"
	desc = "The Candy Man can 'cause he mixes it with love."
	icon_state = "gummywormcustom"
	baseicon = "gummywormcustom"
	basename = "flavored giant gummy worm"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/candy/jellybean
	name = "flavored giant jelly bean"
	desc = "And makes the world taste good."
	icon_state = "jellybeancustom"
	baseicon = "jellybeancustom"
	basename = "flavored giant jelly bean"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/candy/jawbreaker
	name = "flavored jawbreaker"
	desc = "Who can take a rainbow, Wrap it in a sigh."
	icon_state = "jawbreakercustom"
	baseicon = "jawbreakercustom"
	basename = "flavored jawbreaker"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/candy/candycane
	name = "flavored candy cane"
	desc = "Soak it in the sun and make strawberry-lemon pie."
	icon_state = "candycanecustom"
	baseicon = "candycanecustom"
	basename = "flavored candy cane"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/candy/gum
	name = "flavored gum"
	desc = "The Candy Man can 'cause he mixes it with love and makes the world taste good. And the world tastes good 'cause the Candy Man thinks it should..."
	icon_state = "gumcustom"
	baseicon = "gumcustom"
	basename = "flavored gum"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/candy/donut
	name = "filled donut"
	desc = "Donut eat this!" // kill me
	icon_state = "donutcustom"
	baseicon = "donutcustom"
	basename = "filled donut"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/candy/sucker
	name = "flavored sucker"
	desc = "Suck suck suck."
	icon_state = "suckercustom"
	baseicon = "suckercustom"
	basename = "flavored sucker"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/candy/cash
	name = "flavored chocolate cash"
	desc = "I got piles!"
	icon_state = "cashcustom"
	baseicon = "cashcustom"
	basename = "flavored cash"
	snack_overlays = 0
	top = 0

/obj/item/food/customizable/candy/coin
	name = "flavored chocolate coin"
	desc = "Clink, clink, clink."
	icon_state = "coincustom"
	baseicon = "coincustom"
	basename = "flavored coin"
	snack_overlays = 0
	top = 0

/// In the event you fuckers find something I forgot to add a customizable food for.
/obj/item/food/customizable/fullycustom
	name = "on a plate"
	desc = "A unique dish."
	icon_state = "fullycustom"
	baseicon = "fullycustom"
	basename = "on a plate"
	snack_overlays = 0
	top = 0
	ingredient_limit = 20
	fullycustom = 1

/obj/item/food/customizable/soup
	name = "soup"
	desc = "A bowl with liquid and... stuff in it."
	icon_state = "soup"
	baseicon = "soup"
	basename = "soup"
	consume_sound = 'sound/items/drink.ogg'
	snack_overlays = 0
	trash = /obj/item/trash/bowl
	top = 0
	tastes = list("soup" = 1)

/obj/item/food/customizable/burger
	name = "burger bun"
	desc = "A bun for a burger. Delicious."
	icon_state = "burgercustom"
	baseicon = "burgercustom"
	basename = "burger"
	tastes = list("bun" = 4)


/obj/item/food/customizable/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/kitchen/utensil) || is_pen(used))
		return ..()

	if(!istype(used, /obj/item/food))
		to_chat(user, "<span class='warning'>[used] isn't exactly something that you would want to eat.</span>")
		return ITEM_INTERACT_COMPLETE

	add_ingredient(used, user)
	return ITEM_INTERACT_COMPLETE

/**
 * Tries to add one ingredient and it's ingredients, if any and applicable, to this snack
 *
 * Arguments:
 * * snack - The ingredient that will be added
 */
/obj/item/food/customizable/proc/add_ingredient(obj/item/food/snack, mob/user)
	if(length(ingredients) > ingredient_limit)
		to_chat(user, "<span class='warning'>If you put anything else in or on [src] it's going to make a mess.</span>")
		return

	// Fully custom snacks don't add the ingredients. So no need to check
	if(!fullycustom && istype(snack, /obj/item/food/customizable))
		var/obj/item/food/customizable/origin = snack
		if(length(ingredients) + length(origin.ingredients) > ingredient_limit)
			to_chat(user, "<span class='warning'>Merging [snack] and [src] together is going to make a mess.</span>")
			return

	if(!user.unequip(snack))
		to_chat(user, "<span class='warning'>[snack] is stuck to your hand!</span>")
		return

	to_chat(user, "<span class='notice'>You add [snack] to [src].</span>")
	snack.reagents.trans_to(src, snack.reagents.total_volume)

	var/list/added_ingredients = list(snack)

	// Only merge when it is not fullycustom. Else it looks weird
	if(!fullycustom && istype(snack, /obj/item/food/customizable))
		var/obj/item/food/customizable/origin = snack
		added_ingredients += origin.ingredients
		origin.ingredients.Cut()
		origin.name = initial(origin.name) // Reset the name for the examine text

	cooktype[basename] = TRUE
	snack.forceMove(src)
	add_ingredients(added_ingredients)

	name = newname()

/**
 * Adds a list of ingredients to the existing snack. Updates the overlays as well
 *
 * Arguments:
 * * new_ingredients - The new ingredients to be added
 */
/obj/item/food/customizable/proc/add_ingredients(list/new_ingredients)
	cut_overlay(top_image) // Remove the top image so we can change it again

	var/ingredient_num = length(ingredients)
	ingredients += new_ingredients
	for(var/obj/item/food/food as anything in new_ingredients)
		ingredient_num++
		var/image/ingredient_image
		if(!fullycustom)
			ingredient_image = new(icon, "[baseicon]_filling")
			if(!food.filling_color == "#FFFFFF")
				ingredient_image.color = food.filling_color
			else
				ingredient_image.color = pick("#FF0000", "#0000FF", "#008000", "#FFFF00")
			if(snack_overlays)
				ingredient_image.pixel_x = rand(2) - 1
				ingredient_image.pixel_y = ingredient_num * 2 + 1
		else
			ingredient_image = new(food.icon, food.icon_state)
			ingredient_image.pixel_x = rand(2) - 1
			ingredient_image.pixel_y = rand(2) - 1
			add_overlay(food.overlays)

		add_overlay(ingredient_image)

	if(top_image)
		top_image.pixel_x = rand(2) - 1
		top_image.pixel_y = ingredient_num * 2 + 1
		add_overlay(top_image)


/obj/item/food/customizable/Destroy()
	QDEL_LIST_CONTENTS(ingredients)
	qdel(top_image)
	return ..()


/obj/item/food/customizable/examine(mob/user)
	. = ..()
	if(LAZYLEN(ingredients))
		var/whatsinside = pick(ingredients)
		. += "<span class='notice'>You think you can see [whatsinside] in there.</span>"


/obj/item/food/customizable/proc/newname()
	var/unsorteditems[0]
	var/sorteditems[0]
	var/unsortedtypes[0]
	var/sortedtypes[0]
	var/endpart = ""
	var/c = 0
	var/ci = 0
	var/ct = 0
	var/seperator = ""
	var/sendback = ""
	var/list/levels = list("", "double", "triple", "quad", "huge")

	for(var/obj/item/ing in ingredients)
		if(istype(ing, /obj/item/shard))
			continue


		if(istype(ing, /obj/item/food/customizable))				// split the ingredients into ones with basenames (sandwich, burger, etc) and ones without, keeping track of how many of each there are
			var/obj/item/food/customizable/gettype = ing
			if(unsortedtypes[gettype.basename])
				unsortedtypes[gettype.basename]++
				if(unsortedtypes[gettype.basename] > ct)
					ct = unsortedtypes[gettype.basename]
			else
				(unsortedtypes[gettype.basename]) = 1
				if(unsortedtypes[gettype.basename] > ct)
					ct = unsortedtypes[gettype.basename]
		else
			if(unsorteditems[ing.name])
				unsorteditems[ing.name]++
				if(unsorteditems[ing.name] > ci)
					ci = unsorteditems[ing.name]
			else
				unsorteditems[ing.name] = 1
				if(unsorteditems[ing.name] > ci)
					ci = unsorteditems[ing.name]

	sorteditems = sortlist(unsorteditems, ci)				//order both types going from the lowest number to the highest number
	sortedtypes = sortlist(unsortedtypes, ct)

	for(var/ings in sorteditems)			   //add the non-basename items to the name, sorting out the , and the and
		c++
		if(c == length(sorteditems) - 1)
			seperator = " and "
		else if(c == length(sorteditems))
			seperator = " "
		else
			seperator = ", "

		if(sorteditems[ings] > length(levels))
			sorteditems[ings] = length(levels)

		if(sorteditems[ings] <= 1)
			sendback +="[ings][seperator]"
		else
			sendback +="[levels[sorteditems[ings]]] [ings][seperator]"

	for(var/ingtype in sortedtypes)   // now add the types basenames, keeping the src one seperate so it can go on the end
		if(sortedtypes[ingtype] > length(levels))
			sortedtypes[ingtype] = length(levels)
		if(ingtype == basename)
			if(sortedtypes[ingtype] < length(levels))
				sortedtypes[ingtype]++
			endpart = "[levels[sortedtypes[ingtype]]] decker [basename]"
			continue
		if(sortedtypes[ingtype] >= 2)
			sendback += "[levels[sortedtypes[ingtype]]] decker [ingtype] "
		else
			sendback += "[ingtype] "

	if(endpart)
		sendback += endpart
	else
		sendback += basename

	if(length(sendback) > 80)
		sendback = "[pick("absurd", "colossal", "enormous", "ridiculous", "massive", "oversized", "cardiac-arresting", "pipe-clogging", "edible but sickening", "sickening", "gargantuan", "mega", "belly-burster", "chest-burster")] [basename]"
	return sendback

/obj/item/food/customizable/proc/sortlist(list/unsorted, highest)
	var/sorted[0]
	for(var/i = 1, i<= highest, i++)
		for(var/it in unsorted)
			if(unsorted[it] == i)
				sorted[it] = i
	return sorted
