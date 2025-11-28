////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/drinks
	name = "drink"
	desc = "yummy!"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	container_type = OPENCONTAINER
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	volume = 50
	var/consume_sound = 'sound/items/drink.ogg'
	var/chugging = FALSE

/obj/item/reagent_containers/drinks/mob_act(mob/target, mob/living/user)
	. = TRUE
	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>None of [src] left, oh no!</span>")
		return

	if(!is_drainable())
		to_chat(user, "<span class='warning'>You need to open [src] first!</span>")
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.drink(src, user)

/obj/item/reagent_containers/drinks/MouseDrop(atom/over_object) //CHUG! CHUG! CHUG!
	if(!iscarbon(over_object))
		return
	var/mob/living/carbon/chugger = over_object
	if(!(container_type & DRAINABLE))
		to_chat(chugger, "<span class='notice'>You need to open [src] first!</span>")
		return
	if(reagents.total_volume && loc == chugger && src == chugger.get_active_hand())
		chugger.visible_message("<span class='notice'>[chugger] raises [src] to [chugger.p_their()] mouth and starts [pick("chugging","gulping")] it down like [pick("a savage","a mad beast","it's going out of style","there's no tomorrow")]!</span>",
			"<span class='notice'>You start chugging [src].</span>",
			"<span class='notice'>You hear what sounds like gulping.</span>")
		chugging = TRUE
		while(do_after_once(chugger, 4 SECONDS, TRUE, chugger, null, "You stop chugging [src]."))
			chugger.drink(src, chugger, 25) //Half of a glass, quarter of a bottle.
			if(!reagents.total_volume) //Finish in style.
				chugger.emote("gasp")
				chugger.visible_message("<span class='notice'>[chugger] [pick("finishes","downs","polishes off","slams")] the entire [src], what a [pick("savage","monster","champ","beast")]!</span>",
					"<span class='notice'>You finish off [src]![prob(50) ? " Maybe that wasn't such a good idea..." : ""]</span>",
					"<span class='notice'>You hear a gasp and a clink.</span>")
				break
		chugging = FALSE

/obj/item/reagent_containers/drinks/normal_act(obj/target, mob/living/user) // The 2 if checks are forced true to preserve tapping behaviour.
	if(chugging)
		return TRUE

	if(target.is_refillable() && is_drainable()) //Something like a glass. Player probably wants to transfer TO it.
		. = TRUE
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty.</span>")
			return

		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		. = TRUE
		if(!is_refillable())
			to_chat(user, "<span class='warning'>[src]'s tab isn't open!</span>")
			return
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty.</span>")
			return

		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

/obj/item/reagent_containers/drinks/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(!reagents || reagents.total_volume == 0)
			. += "<span class='notice'>[src] is empty!</span>"
		else if(reagents.total_volume <= volume/4)
			. += "<span class='notice'>[src] is almost empty!</span>"
		else if(reagents.total_volume <= volume*0.66)
			. += "<span class='notice'>[src] is half full!</span>"// We're all optimistic, right?!

		else if(reagents.total_volume <= volume*0.90)
			. += "<span class='notice'>[src] is almost full!</span>"
		else
			. += "<span class='notice'>[src] is full!</span>"

////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/reagent_containers/drinks/trophy
	name = "pewter cup"
	desc = "Everyone gets a trophy."
	icon_state = "pewter_cup"
	force = 1
	throwforce = 1
	materials = list(MAT_METAL=100)
	possible_transfer_amounts = null
	volume = 5
	flags = CONDUCT
	resistance_flags = FIRE_PROOF

/obj/item/reagent_containers/drinks/trophy/gold_cup
	name = "gold cup"
	desc = "You're winner!"
	icon_state = "golden_cup"
	w_class = WEIGHT_CLASS_BULKY
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	materials = list(MAT_GOLD=1000)
	volume = 150

/obj/item/reagent_containers/drinks/trophy/silver_cup
	name = "silver cup"
	desc = "Best loser!"
	icon_state = "silver_cup"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	throwforce = 8
	amount_per_transfer_from_this = 15
	materials = list(MAT_SILVER=800)
	volume = 100

/obj/item/reagent_containers/drinks/trophy/bronze_cup
	name = "bronze cup"
	desc = "At least you ranked!"
	icon_state = "bronze_cup"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 4
	amount_per_transfer_from_this = 10
	materials = list(MAT_METAL=400)
	volume = 25

/// 2023 toolbox tournament 3rd place went to paradise station.
/obj/item/reagent_containers/drinks/trophy/bronze_cup/toolbox_win
	name = "3rd place toolbox tournament 2567"
	desc = "Awarded to CentComm's elite toolbox warriors raising money for the GBS research institute."
	icon_state = "reward_cup"
	force = 10.3
	throwforce = 10.3

///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/obj/item/reagent_containers/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	list_reagents = list("coffee" = 30)
	resistance_flags = FREEZE_PROOF

/obj/item/reagent_containers/drinks/ice
	name = "ice cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "icecup"
	list_reagents = list("ice" = 30)

/obj/item/reagent_containers/drinks/tea
	name = "Duke Purple tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "teacup"
	inhand_icon_state = "coffee"
	list_reagents = list("tea" = 30)

/obj/item/reagent_containers/drinks/tea/Initialize(mapload)
	. = ..()
	if(prob(20))
		reagents.add_reagent("mugwort", 3)

/obj/item/reagent_containers/drinks/mugwort
	name = "mugwort tea"
	desc = "A bitter herbal tea."
	icon_state = "manlydorfglass"
	inhand_icon_state = "coffee"
	list_reagents = list("mugwort" = 30)

/obj/item/reagent_containers/drinks/h_chocolate
	name = "Dutch hot coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	inhand_icon_state = "coffee"
	list_reagents = list("hot_coco" = 30, "sugar" = 5)
	resistance_flags = FREEZE_PROOF

/obj/item/reagent_containers/drinks/chocolate
	name = "hot chocolate"
	desc = "Made in Space Switzerland."
	icon_state = "hot_coco"
	inhand_icon_state = "coffee"
	list_reagents = list("hot_coco" = 15, "chocolate" = 6, "water" = 9)
	resistance_flags = FREEZE_PROOF

/obj/item/reagent_containers/drinks/weightloss
	name = "weight-loss shake"
	desc = "A shake designed to cause weight loss, now in a berry-flavored formulation. The package proudly proclaims that it is 'tapeworm free.'"
	icon_state = "weightshake"
	list_reagents = list("lipolicide" = 30, "berryjuice" = 5)

/obj/item/reagent_containers/drinks/dry_ramen
	name = "cup ramen"
	desc = "Just add 10ml of water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"
	list_reagents = list("dry_ramen" = 30)

/obj/item/reagent_containers/drinks/dry_ramen/Initialize(mapload)
	. = ..()
	if(prob(20))
		reagents.add_reagent("enzyme", 3)

/obj/item/reagent_containers/drinks/chicken_soup
	name = "canned chicken soup"
	desc = "A delicious and soothing can of chicken noodle soup; just like spessmom used to microwave it."
	icon_state = "soupcan"
	list_reagents = list("chicken_soup" = 30)

/obj/item/reagent_containers/drinks/sillycup
	name = "paper cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	inhand_icon_state = "coffee"
	possible_transfer_amounts = null
	volume = 10

/obj/item/reagent_containers/drinks/sillycup/on_reagent_change()
	if(reagents.total_volume)
		icon_state = "water_cup"
	else
		icon_state = "water_cup_e"

//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/reagent_containers/drinks/shaker
	name = "shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	materials = list(MAT_METAL=1500)
	amount_per_transfer_from_this = 10
	volume = 100
	var/shaking = FALSE

	COOLDOWN_DECLARE(shaking_cooldown)

/obj/item/reagent_containers/drinks/shaker/Initialize(mapload)
	. = ..()
	reagents.set_reacting(FALSE)

/obj/item/reagent_containers/drinks/shaker/activate_self(mob/user)
	if(..())
		return

	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>You won't shake an empty shaker now, will you?</span>")
		return

	if(COOLDOWN_FINISHED(src, shaking_cooldown))
		shaking = TRUE
		var/adjective = pick("furiously", "passionately", "with vigor", "with determination", "like a devil", "with care and love", "like there is no tomorrow")
		user.visible_message("<span class='notice'>[user] shakes [src] [adjective]!</span>", "<span class='notice'>You shake [src] [adjective]!</span>")
		icon_state = "shaker-shake"
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.update_inv_r_hand()
			M.update_inv_l_hand()
		playsound(user, 'sound/items/boston_shaker.ogg', 80, TRUE)
		COOLDOWN_START(src, shaking_cooldown, 3 SECONDS)

	if(shaking)
		if(do_after_once(user, 3 SECONDS, target = src, allow_moving = TRUE, attempt_cancel_message = "You stop shaking [src] before it has time to mix."))
			reagents.set_reacting(TRUE)
			reagents.handle_reactions()
	icon_state = "shaker"
	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		M.update_inv_r_hand()
		M.update_inv_l_hand()

	shaking = FALSE
	reagents.set_reacting(FALSE)

/obj/item/reagent_containers/drinks/shaker/dropped(mob/user)
	. = ..()
	icon_state = "shaker"

/obj/item/reagent_containers/drinks/flask
	name = "flask"
	desc = "Every good spaceman knows it's a good idea to bring along a couple of pints of whiskey wherever they go."
	icon_state = "flask"
	materials = list(MAT_METAL=250)
	volume = 60

/obj/item/reagent_containers/drinks/flask/barflask
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"

/obj/item/reagent_containers/drinks/flask/gold
	name = "captain's flask"
	desc = "A regal flask belonging to the captain, with Nanotrasen's logo inlaid with pearl."
	icon_state = "flask_gold"
	materials = list(MAT_GOLD=500)

/obj/item/reagent_containers/drinks/flask/detflask
	name = "detective's flask"
	desc = "The detective's only true friend."
	icon_state = "detflask"
	list_reagents = list("whiskey" = 30)

/obj/item/reagent_containers/drinks/flask/hand_made
	name = "handmade flask"
	desc = "A wooden flask with a silver lid and bottom. It has a matte, dark blue paint on it with the initials \"W.H.\" etched in black."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "williamhackett"
	materials = list()

/obj/item/reagent_containers/drinks/flask/thermos
	name = "vintage thermos"
	desc = "An older thermos with a faint shine."
	icon_state = "thermos"
	volume = 50

/obj/item/reagent_containers/drinks/flask/shiny
	name = "shiny flask"
	desc = "A shiny metal flask. It appears to have a Greek symbol inscribed on it."
	icon_state = "shinyflask"
	volume = 50

/obj/item/reagent_containers/drinks/flask/lithium
	name = "lithium flask"
	desc = "A flask with a Lithium Atom symbol on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lithiumflask"
	volume = 50


/obj/item/reagent_containers/drinks/britcup
	name = "cup"
	desc = "A cup with the british flag emblazoned on it."
	icon_state = "britcup"
	volume = 30

/obj/item/reagent_containers/drinks/bag
	name = "drink bag"
	desc = "Normally put in wine boxes, or down pants at stadium events."
	icon_state = "goonbag"
	volume = 70

/obj/item/reagent_containers/drinks/bag/goonbag
	name = "goon from a Blue Toolbox special edition"
	desc = "Wine from the land down under, where the dingos roam and the roos do wander."
	list_reagents = list("wine" = 70)

/obj/item/reagent_containers/drinks/oilcan
	name = "oil can"
	desc = "Contains oil intended for use on cyborgs, robots, and other synthetics."
	icon = 'icons/goonstation/objects/oil.dmi'
	icon_state = "oilcan"
	volume = 100

/obj/item/reagent_containers/drinks/oilcan/full
	list_reagents = list("oil" = 100)
