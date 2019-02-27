////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food/drinks
	name = "drink"
	desc = "yummy"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	container_type = OPENCONTAINER
	consume_sound = 'sound/items/drink.ogg'
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	volume = 50
	burn_state = FIRE_PROOF

/obj/item/reagent_containers/food/drinks/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	bitesize = amount_per_transfer_from_this
	if(bitesize < 5)
		bitesize = 5

/obj/item/reagent_containers/food/drinks/attack_self(mob/user)
	return

/obj/item/reagent_containers/food/drinks/attack(mob/M, mob/user, def_zone)
	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'> None of [src] left, oh no!</span>")
		return FALSE

	if(!is_drainable())
		to_chat(user, "<span class='warning'> You need to open [src] first!</span>")
		return FALSE

	if(istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		if(C.eat(src, user))
			if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
				var/mob/living/silicon/robot/borg = user
				borg.cell.use(30)
				var/refill = reagents.get_master_reagent_id()
				if(refill in GLOB.drinks) // Only synthesize drinks
					addtimer(CALLBACK(reagents, /datum/reagents.proc/add_reagent, refill, bitesize), 600)
			return TRUE
	return FALSE

/obj/item/reagent_containers/food/drinks/MouseDrop(atom/over_object) //CHUG! CHUG! CHUG!
	var/mob/living/carbon/chugger = over_object
	if (!(container_type & DRAINABLE))
		to_chat(chugger, "<span class='notice'>You need to open [src] first!</span>")
		return
	if(istype(chugger) && loc == chugger && src == chugger.get_active_hand() && reagents.total_volume)
		chugger.visible_message("<span class='notice'>[chugger] raises the [src] to [chugger.p_their()] mouth and starts [pick("chugging","gulping")] it down like [pick("a savage","a mad beast","it's going out of style","there's no tomorrow")]!</span>", "<span class='notice'>You start chugging [src].</span>", "<span class='notice'>You hear what sounds like gulping.</span>")
		while(do_mob(chugger, chugger, 40)) //Between the default time for do_mob and the time it takes for a vampire to suck blood.
			chugger.eat(src, chugger, 25) //Half of a glass, quarter of a bottle.
			if(!reagents.total_volume) //Finish in style.
				chugger.emote("gasp")
				chugger.visible_message("<span class='notice'>[chugger] [pick("finishes","downs","polishes off","slams")] the entire [src], what a [pick("savage","monster","champ","beast")]!</span>", "<span class='notice'>You finish off the [src]![prob(50) ? " Maybe that wasn't such a good idea..." : ""]</span>", "<span class='notice'>You hear a gasp and a clink.</span>")
				break

/obj/item/reagent_containers/food/drinks/afterattack(obj/target, mob/user, proximity)
	if(!proximity)
		return

	if(target.is_refillable() && is_drainable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'> [src] is empty.</span>")
			return FALSE

		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'> [target] is full.</span>")
			return FALSE

		var/datum/reagent/refill
		var/datum/reagent/refillName
		if(isrobot(user))
			refill = reagents.get_master_reagent_id()
			refillName = reagents.get_master_reagent_name()

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'> You transfer [trans] units of the solution to [target].</span>")

		if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			if(refill in GLOB.drinks) // Only synthesize drinks
				var/mob/living/silicon/robot/bro = user
				var/chargeAmount = max(30,4*trans)
				bro.cell.use(chargeAmount)
				to_chat(user, "<span class='notice'>Now synthesizing [trans] units of [refillName]...</span>")
				addtimer(CALLBACK(reagents, /datum/reagents.proc/add_reagent, refill, trans), 300)
				addtimer(CALLBACK(GLOBAL_PROC, .proc/__to_chat, user, "<span class='notice'>Cyborg [src] refilled.</span>"), 300)

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!is_refillable())
			to_chat(user, "<span class='warning'>[src]'s tab isn't open!</span>")
			return FALSE
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty.</span>")
			return FALSE

		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return FALSE

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	return FALSE

/obj/item/reagent_containers/food/drinks/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/mask/cigarette)) //ciggies are weird
		return FALSE
	if(is_hot(I))
		if(reagents)
			reagents.chem_temp += 15
			to_chat(user, "<span class='notice'>You heat [src] with [I].</span>")
			reagents.handle_reactions()
	else
		return ..()

/obj/item/reagent_containers/food/drinks/examine(mob/user)
	if(!..(user, 1))
		return
	if(!reagents || reagents.total_volume == 0)
		to_chat(user, "<span class='notice'> \The [src] is empty!</span>")
	else if(reagents.total_volume <= volume/4)
		to_chat(user, "<span class='notice'> \The [src] is almost empty!</span>")
	else if(reagents.total_volume <= volume*0.66)
		to_chat(user, "<span class='notice'> \The [src] is half full!</span>")// We're all optimistic, right?!

	else if(reagents.total_volume <= volume*0.90)
		to_chat(user, "<span class='notice'> \The [src] is almost full!</span>")
	else
		to_chat(user, "<span class='notice'> \The [src] is full!</span>")

////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/food/drinks/trophy
	name = "pewter cup"
	desc = "Everyone gets a trophy."
	icon_state = "pewter_cup"
	w_class = WEIGHT_CLASS_TINY
	force = 1
	throwforce = 1
	amount_per_transfer_from_this = 5
	materials = list(MAT_METAL=100)
	possible_transfer_amounts = list()
	volume = 5
	flags = CONDUCT
	container_type = OPENCONTAINER

/obj/item/reagent_containers/food/drinks/trophy/gold_cup
	name = "gold cup"
	desc = "You're winner!"
	icon_state = "golden_cup"
	w_class = WEIGHT_CLASS_BULKY
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	materials = list(MAT_GOLD=1000)
	volume = 150

/obj/item/reagent_containers/food/drinks/trophy/silver_cup
	name = "silver cup"
	desc = "Best loser!"
	icon_state = "silver_cup"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	throwforce = 8
	amount_per_transfer_from_this = 15
	materials = list(MAT_SILVER=800)
	volume = 100

/obj/item/reagent_containers/food/drinks/trophy/bronze_cup
	name = "bronze cup"
	desc = "At least you ranked!"
	icon_state = "bronze_cup"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 4
	amount_per_transfer_from_this = 10
	materials = list(MAT_METAL=400)
	volume = 25


///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.


/obj/item/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	list_reagents = list("coffee" = 30)

/obj/item/reagent_containers/food/drinks/ice
	name = "ice cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "icecup"
	list_reagents = list("ice" = 30)

/obj/item/reagent_containers/food/drinks/tea
	name = "Duke Purple tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "teacup"
	item_state = "coffee"
	list_reagents = list("tea" = 30)

/obj/item/reagent_containers/food/drinks/tea/New()
	..()
	if(prob(20))
		reagents.add_reagent("mugwort", 3)

/obj/item/reagent_containers/food/drinks/mugwort
	name = "mugwort tea"
	desc = "A bitter herbal tea."
	icon_state = "manlydorfglass"
	item_state = "coffee"
	list_reagents = list("mugwort" = 30)

/obj/item/reagent_containers/food/drinks/h_chocolate
	name = "Dutch hot coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	item_state = "coffee"
	list_reagents = list("hot_coco" = 30, "sugar" = 5)

/obj/item/reagent_containers/food/drinks/chocolate
	name = "hot chocolate"
	desc = "Made in Space Switzerland."
	icon_state = "hot_coco"
	item_state = "coffee"
	list_reagents = list("chocolate" = 30)

/obj/item/reagent_containers/food/drinks/weightloss
	name = "weight-loss shake"
	desc = "A shake designed to cause weight loss.  The package proudly proclaims that it is 'tapeworm free.'"
	icon_state = "weightshake"
	list_reagents = list("lipolicide" = 30, "chocolate" = 5)

/obj/item/reagent_containers/food/drinks/dry_ramen
	name = "cup ramen"
	desc = "Just add 10ml of water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	item_state = "ramen"
	list_reagents = list("dry_ramen" = 30)

/obj/item/reagent_containers/food/drinks/dry_ramen/New()
	..()
	if(prob(20))
		reagents.add_reagent("enzyme", 3)

/obj/item/reagent_containers/food/drinks/chicken_soup
	name = "canned chicken soup"
	desc = "A delicious and soothing can of chicken noodle soup; just like spessmom used to microwave it."
	icon_state = "soupcan"
	item_state = "soupcan"
	list_reagents = list("chicken_soup" = 30)

/obj/item/reagent_containers/food/drinks/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	item_state = "coffee"
	possible_transfer_amounts = list()
	volume = 10

/obj/item/reagent_containers/food/drinks/sillycup/on_reagent_change()
	if(reagents.total_volume)
		icon_state = "water_cup"
	else
		icon_state = "water_cup_e"

//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/reagent_containers/food/drinks/shaker
	name = "shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	materials = list(MAT_METAL=1500)
	amount_per_transfer_from_this = 10
	volume = 100

/obj/item/reagent_containers/food/drinks/flask
	name = "flask"
	desc = "Every good spaceman knows it's a good idea to bring along a couple of pints of whiskey wherever they go."
	icon_state = "flask"
	materials = list(MAT_METAL=250)
	volume = 60

/obj/item/reagent_containers/food/drinks/flask/barflask
	name = "flask"
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"

/obj/item/reagent_containers/food/drinks/flask/gold
	name = "captain's flask"
	desc = "A gold flask belonging to the captain."
	icon_state = "flask_gold"
	materials = list(MAT_GOLD=500)

/obj/item/reagent_containers/food/drinks/flask/detflask
	name = "detective's flask"
	desc = "The detective's only true friend."
	icon_state = "detflask"
	list_reagents = list("whiskey" = 30)

/obj/item/reagent_containers/food/drinks/flask/hand_made
	name = "handmade flask"
	desc = "A wooden flask with a silver lid and bottom. It has a matte, dark blue paint on it with the initials \"W.H.\" etched in black."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "williamhackett"
	materials = list()

/obj/item/reagent_containers/food/drinks/flask/thermos
	name = "vintage thermos"
	desc = "An older thermos with a faint shine."
	icon_state = "thermos"
	volume = 50

/obj/item/reagent_containers/food/drinks/flask/shiny
	name = "shiny flask"
	desc = "A shiny metal flask. It appears to have a Greek symbol inscribed on it."
	icon_state = "shinyflask"
	volume = 50

/obj/item/reagent_containers/food/drinks/flask/lithium
	name = "lithium flask"
	desc = "A flask with a Lithium Atom symbol on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lithiumflask"
	volume = 50


/obj/item/reagent_containers/food/drinks/britcup
	name = "cup"
	desc = "A cup with the british flag emblazoned on it."
	icon_state = "britcup"
	volume = 30

/obj/item/reagent_containers/food/drinks/mushroom_bowl
	name = "mushroom bowl"
	desc = "A bowl made out of mushrooms. Not food, though it might have contained some at some point."
	icon = 'icons/obj/lavaland/ash_flora.dmi'
	icon_state = "mushroom_bowl"
	w_class = WEIGHT_CLASS_SMALL


/obj/item/reagent_containers/food/drinks/bag
	name = "drink bag"
	desc = "Normally put in wine boxes, or down pants at stadium events."
	icon_state = "goonbag"
	volume = 70

/obj/item/reagent_containers/food/drinks/bag/goonbag
	name = "goon from a Blue Toolbox special edition"
	desc = "Wine from the land down under, where the dingos roam and the roos do wander."
	icon_state = "goonbag"
	list_reagents = list("wine" = 70)

/obj/item/reagent_containers/food/drinks/waterbottle
	name = "bottle of water"
	desc = "A bottle of water filled at an old Earth bottling facility."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "smallbottle"
	item_state = "bottle"
	list_reagents = list("water" = 49.5, "fluorine" = 0.5) //see desc, don't think about it too hard
	materials = list(MAT_GLASS = 0)
	volume = 50
	amount_per_transfer_from_this = 10

/obj/item/reagent_containers/food/drinks/waterbottle/empty
	list_reagents = list()

/obj/item/reagent_containers/food/drinks/waterbottle/large
	desc = "A fresh commercial-sized bottle of water."
	icon_state = "largebottle"
	materials = list(MAT_GLASS = 0)
	list_reagents = list("water" = 100)
	volume = 100
	amount_per_transfer_from_this = 20

/obj/item/reagent_containers/food/drinks/waterbottle/large/empty
	list_reagents = list()

/obj/item/reagent_containers/food/drinks/oilcan
	name = "oil can"
	desc = "Contains oil intended for use on cyborgs, robots, and other synthetics."
	icon = 'icons/goonstation/objects/oil.dmi'
	icon_state = "oilcan"
	volume = 100

/obj/item/reagent_containers/food/drinks/oilcan/full
	list_reagents = list("oil" = 100)
