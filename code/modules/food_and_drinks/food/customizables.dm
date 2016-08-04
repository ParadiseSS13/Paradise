/obj/item/weapon/reagent_containers/food/snacks/breadslice/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/bun/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/burger/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)
	else
		..()


/obj/item/weapon/reagent_containers/food/snacks/boiledspagetti/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)
	else
		..()


/obj/item/trash/plate/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)
	else
		..()

/obj/item/trash/bowl
	name = "bowl"
	desc = "An empty bowl. Put some food in it to start making a soup."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "soup"

/obj/item/trash/bowl/attackby(obj/item/W as obj, mob/user as mob, params)

	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks) && !(W.flags & NODROP))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/soup/S = new(get_turf(user))
		S.attackby(W,user, params)
		qdel(src)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/customizable/sandwich
	/obj/item/weapon/reagent_containers/food/snacks/customizable
	name = "sandwich"
	desc = "A sandwich! A timeless classic."
	icon_state = "breadslice"
	baseicon = "sandwich"
	basename = "sandwich"
	toptype = new /obj/item/weapon/reagent_containers/food/snacks/breadslice()



/obj/item/weapon/reagent_containers/food/snacks/customizable
	name = "sandwich"
	desc = "A sandwich! A timeless classic."
	icon_state = "breadslice"
	var/baseicon = "sandwich"
	var/basename = "sandwich"
	var/top = 1	//Do we have a top?
	var/obj/item/toptype
	var/add_overlays = 1	//Do we stack?
//	var/offsetstuff = 1 //Do we offset the overlays?
	var/sandwich_limit = 40
	var/fullycustom = 0
	trash = /obj/item/trash/plate
	bitesize = 2
	var/list/ingredients = list()

	New()
		..()

		reagents.add_reagent("nutriment", 8)


/obj/item/weapon/reagent_containers/food/snacks/customizable/pizza
	name = "personal pizza"
	desc = "A personalized pan pizza meant for only one person."
	icon_state = "personal_pizza"
	baseicon = "personal_pizza"
	basename = "personal pizza"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/pasta
	name = "spagetti"
	desc = "Noodles. With stuff. Delicious."
	icon_state = "pasta_bot"
	baseicon = "pasta_bot"
	basename = "spagetti"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/bread
	name = "bread"
	desc = "Tasty bread."
	icon_state = "breadcustom"
	baseicon = "breadcustom"
	basename = "bread"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/pie
	name = "pie"
	desc = "Tasty pie."
	icon_state = "piecustom"
	baseicon = "piecustom"
	basename = "pie"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/cake
	name = "cake"
	desc = "A popular band."
	icon_state = "cakecustom"
	baseicon = "cakecustom"
	basename = "cake"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/jelly
	name = "jelly"
	desc = "Totally jelly."
	icon_state = "jellycustom"
	baseicon = "jellycustom"
	basename = "jelly"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/donkpocket
	name = "donk pocket"
	desc = "You wanna put a bangin-Oh nevermind."
	icon_state = "donkcustom"
	baseicon = "donkcustom"
	basename = "donk pocket"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/kebab
	name = "kebab"
	desc = "Kebab or Kabab?"
	icon_state = "kababcustom"
	baseicon = "kababcustom"
	basename = "kebab"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/salad
	name = "salad"
	desc = "Very tasty."
	icon_state = "saladcustom"
	baseicon = "saladcustom"
	basename = "salad"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/cook/waffles
	name = "waffles"
	desc = "Made with love."
	icon_state = "wafflecustom"
	baseicon = "wafflecustom"
	basename = "waffles"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cookie
	name = "cookie"
	desc = "COOKIE!!1!"
	icon_state = "cookiecustom"
	baseicon = "cookiecustom"
	basename = "cookie"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cotton
	name = "flavored cotton candy"
	desc = "Who can take a sunrise, sprinkle it with dew,"
	icon_state = "cottoncandycustom"
	baseicon = "cottoncandycustom"
	basename = "flavored cotton candy"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gummybear
	name = "flavored giant gummy bear"
	desc = "Cover it in chocolate and a miracle or two,"
	icon_state = "gummybearcustom"
	baseicon = "gummybearcustom"
	basename = "flavored giant gummy bear"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gummyworm
	name = "flavored giant gummy worm"
	desc = "The Candy Man can 'cause he mixes it with love,"
	icon_state = "gummywormcustom"
	baseicon = "gummywormcustom"
	basename = "flavored giant gummy worm"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/jellybean
	name = "flavored giant jelly bean"
	desc = "And makes the world taste good."
	icon_state = "jellybeancustom"
	baseicon = "jellybeancustom"
	basename = "flavored giant jelly bean"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/jawbreaker
	name = "flavored jawbreaker"
	desc = "Who can take a rainbow, Wrap it in a sigh,"
	icon_state = "jawbreakercustom"
	baseicon = "jawbreakercustom"
	basename = "flavored jawbreaker"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/candycane
	name = "flavored candy cane"
	desc = "Soak it in the sun and make strawberry-lemon pie,"
	icon_state = "candycanecustom"
	baseicon = "candycanecustom"
	basename = "flavored candy cane"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/gum
	name = "flavored gum"
	desc = "The Candy Man can 'cause he mixes it with love and makes the world taste good. And the world tastes good 'cause the Candy Man thinks it should..."
	icon_state = "gumcustom"
	baseicon = "gumcustom"
	basename = "flavored gum"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/donut
	name = "filled donut"
	desc = "Donut eat this!" // kill me
	icon_state = "donutcustom"
	baseicon = "donutcustom"
	basename = "filled donut"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/bar
	name = "flavored chocolate bar"
	desc = "Made in a factory downtown."
	icon_state = "barcustom"
	baseicon = "barcustom"
	basename = "flavored chocolate bar"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/sucker
	name = "flavored sucker"
	desc = "Suck suck suck."
	icon_state = "suckercustom"
	baseicon = "suckercustom"
	basename = "flavored sucker"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/cash
	name = "flavored chocolate cash"
	desc = "I got piles!"
	icon_state = "cashcustom"
	baseicon = "cashcustom"
	basename = "flavored cash"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/coin
	name = "flavored chocolate coin"
	desc = "Clink, clink, clink."
	icon_state = "coincustom"
	baseicon = "coincustom"
	basename = "flavored coin"
	add_overlays = 0
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/fullycustom // In the event you fuckers find something I forgot to add a customizable food for.
	name = "on a plate"
	desc = "A unique dish."
	icon_state = "fullycustom"
	baseicon = "fullycustom"
	basename = "on a plate"
	add_overlays = 0
	top = 0
	sandwich_limit = 20
	fullycustom = 1

/obj/item/weapon/reagent_containers/food/snacks/customizable/soup
	name = "soup"
	desc = "A bowl with liquid and... stuff in it."
	icon_state = "soup"
	baseicon = "soup"
	basename = "soup"
	add_overlays = 0
	trash = /obj/item/trash/bowl
	top = 0

/obj/item/weapon/reagent_containers/food/snacks/customizable/burger
	name = "burger bun"
	desc = "A bun for a burger. Delicious."
	icon_state = "burger"
	baseicon = "burger"
	basename = "burger"
	toptype = new /obj/item/weapon/reagent_containers/food/snacks/bun()

/obj/item/weapon/reagent_containers/food/snacks/customizable/attackby(obj/item/I, mob/user, params)
	if(src.contents.len > sandwich_limit)
		to_chat(user, "<span class='warning'>If you put anything else in or on [src] it's going to make a mess.</span>")
		return
	if(!istype(I, /obj/item/weapon/reagent_containers/food/snacks))
		to_chat(user, "\The [I] isn't exactly something that you would want to eat.")
		return
	to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
	if(istype(I,  /obj/item/weapon/reagent_containers/))
		var/obj/item/weapon/reagent_containers/F = I
		F.reagents.trans_to(src, F.reagents.total_volume)
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/customizable))
		var/obj/item/weapon/reagent_containers/food/snacks/customizable/origin = I
		ingredients += origin.ingredients
	user.drop_item()
	cooktype[basename] = 1
	I.loc = src
	if(!istype(I, toptype))
		ingredients += I
	updateicon()
	name = newname()


/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/updateicon()
	overlays = 0
	var/i=0
	for(var/obj/item/O in ingredients)
		i++
		if(!fullycustom)
			var/image/I = new(src.icon, "[baseicon]_filling")
			if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
				var/obj/item/weapon/reagent_containers/food/snacks/food = O
				if(!food.filling_color == "#FFFFFF")
					I.color = food.filling_color
				else
					I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
			else
				I.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
			if(add_overlays)
				I.pixel_x = pick(list(-1,0,1))
				I.pixel_y = (i*2)+1
			overlays += I
		else
			var/image/F = new(O.icon, O.icon_state)
			F.pixel_x = pick(list(-1,0,1))
			F.pixel_y = pick(list(-1,0,1))
			overlays += F
			overlays += O.overlays

	if(top)
		var/image/T = new(src.icon, "[baseicon]_top")
		T.pixel_x = pick(list(-1,0,1))
		T.pixel_y = (ingredients.len * 2)+1
		overlays += T

/obj/item/weapon/reagent_containers/food/snacks/customizable/Destroy()
	for(var/obj/item/O in ingredients)
		qdel(O)
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/customizable/examine(mob/user)
	..(user)
	var/whatsinside = pick(ingredients)

	to_chat(user, "<span class='notice'> You think you can see [whatsinside] in there.</span>")

/*
/obj/item/weapon/reagent_containers/food/snacks/customizable/attack(mob/M as mob, mob/user as mob, def_zone) //SNOOOOOOOWFLAAAAAAAAAAAAAAAAAKES

	var/obj/item/shard
	for(var/obj/item/O in contents)
		if(istype(O,/obj/item/weapon/shard))
			shard = O
			break

	var/mob/living/H
	if(istype(M,/mob/living))
		H = M

	if(H && shard && M == user) //This needs a check for feeding the food to other people, but that could be abusable.
		to_chat(H, "\red You lacerate your mouth on a [shard.name] in the sandwich!")
		H.adjustBruteLoss(5) //TODO: Target head if human.
	..()
*/

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/newname()
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
		if(istype(ing, /obj/item/weapon/shard))
			continue


		if(istype(ing, /obj/item/weapon/reagent_containers/food/snacks/customizable))				// split the ingredients into ones with basenames (sandwich, burger, etc) and ones without, keeping track of how many of each there are
			var/obj/item/weapon/reagent_containers/food/snacks/customizable/gettype = ing
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
		if(c == sorteditems.len - 1)
			seperator = " and "
		else if(c == sorteditems.len)
			seperator = " "
		else
			seperator = ", "

		if(sorteditems[ings] > levels.len)
			sorteditems[ings] = levels.len

		if(sorteditems[ings] <= 1)
			sendback +="[ings][seperator]"
		else
			sendback +="[levels[sorteditems[ings]]] [ings][seperator]"

	for(var/ingtype in sortedtypes)   // now add the types basenames, keeping the src one seperate so it can go on the end
		if(sortedtypes[ingtype] > levels.len)
			sortedtypes[ingtype] = levels.len
		if(ingtype == basename)
			if(sortedtypes[ingtype] < levels.len)
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
		sendback = "[pick(list("absurd","colossal","enormous","ridiculous","massive","oversized","cardiac-arresting","pipe-clogging","edible but sickening","sickening","gargantuan","mega","belly-burster","chest-burster"))] [basename]"
	return sendback

/obj/item/weapon/reagent_containers/food/snacks/customizable/proc/sortlist(var/list/unsorted, var/highest)
	var/sorted[0]
	for(var/i = 1, i<= highest, i++)
		for(var/it in unsorted)
			if(unsorted[it] == i)
				sorted[it] = i
	return sorted

