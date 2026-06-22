/obj/item/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/janitor.dmi'
	icon_state = "soap"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 20
	discrete = 1
	new_attack_chain = TRUE
	/// Time taken to clean something.
	var/cleanspeed = 5 SECONDS
	/// How many times a Drask has chewed on this bar of soap.
	var/times_eaten = 0
	/// The maximum amount of bites before the soap is depleted.
	var/max_bites = 30

/obj/item/soap/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, src, 8 SECONDS, 100, 0, FALSE)

/obj/item/soap/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!ismob(target))
		target.cleaning_act(user, src, cleanspeed)
		return ITEM_INTERACT_COMPLETE

	if(!ishuman(target) || user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		return ..() // Cleaning mobs is done on attack() so they get visibly bonked by the soap.

	// Mmm, delicious soap!
	if(isdrask(target) && user == target && user.a_intent == INTENT_GRAB)
		var/mob/living/carbon/human/muncher = target
		eat_soap(muncher)
		user.changeNext_move(CLICK_CD_MELEE)
		return ITEM_INTERACT_COMPLETE

	user.visible_message(
		SPAN_WARNING("[user] starts washing [target == user ? "[target.p_their()] own" : "[target]'s"] mouth out with [src]!"),
		SPAN_NOTICE("You start washing [target == user ? "your own" : "[target]'s"] mouth out with [src]!")
	)
	if(do_after_once(user, cleanspeed, target = target))
		user.visible_message(
			SPAN_WARNING("[user] washes [target == user ? "[target.p_their()] own" : "[target]'s"] mouth out with [src]!"),
			SPAN_WARNING("You wash [target == user ? "your own" : "[target]'s"] mouth out with [src]!")
		)
		target.reagents.add_reagent("soapreagent", 6)
	return ITEM_INTERACT_COMPLETE

/obj/item/soap/attack(mob/living/target, mob/living/user, params)
	..()
	target.cleaning_act(user, src, cleanspeed)
	return FINISH_ATTACK

/obj/item/soap/add_blood(list/blood_dna, b_color)
	return

/obj/item/soap/proc/eat_soap(mob/living/carbon/human/drask/user)
	times_eaten++
	playsound(user.loc, 'sound/items/eatfood.ogg', 50, 0)
	user.adjust_nutrition(5)
	user.reagents.add_reagent("soapreagent", 3)
	if(times_eaten < max_bites)
		to_chat(user, SPAN_NOTICE("You take a bite of [src]. Delicious!"))
	else
		to_chat(user, SPAN_NOTICE("You finish eating [src]."))
		qdel(src)

/obj/item/soap/examine(mob/user)
	. = ..()
	if(!user.Adjacent(src) || !times_eaten)
		return
	if(times_eaten < (max_bites * 0.3))
		. += SPAN_NOTICE("[src] has bite marks on it!")
	else if(times_eaten < (max_bites * 0.6))
		. += SPAN_NOTICE("Big chunks of [src] have been chewed off!")
	else if(times_eaten < (max_bites * 0.9))
		. += SPAN_NOTICE("Most of [src] has been gnawed away!")
	else
		. += SPAN_NOTICE("[src] has been eaten down to a sliver!")

/obj/item/soap/can_clean()
	return TRUE

/obj/item/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"

/obj/item/soap/homemade
	desc = "A homemade bar of soap. Smells of... well...."
	icon_state = "soaphome"
	cleanspeed = 4.5 SECONDS // A little faster to reward chemists for going to the effort.

/obj/item/soap/ducttape
	desc = "A homemade bar of soap. It seems to be gibs and tape..Will this clean anything?"
	icon_state = "soapgibs"

/obj/item/soap/ducttape/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(user.client && (target in user.client.screen))
		to_chat(user, SPAN_NOTICE("You need to take [target] off before 'cleaning' it."))
		return ITEM_INTERACT_COMPLETE

	user.visible_message(SPAN_WARNING("[user] begins to smear [src] on [target]."))
	if(!do_after(user, cleanspeed, target = target))
		return ITEM_INTERACT_COMPLETE

	to_chat(user, SPAN_NOTICE("You 'clean' [target]."))
	if(issimulatedturf(target))
		new /obj/effect/decal/cleanable/blood/gibs/cleangibs(target)
		return ITEM_INTERACT_COMPLETE

	if(iscarbon(target))
		for(var/obj/item/carried_item in target.contents)
			if(!istype(carried_item, /obj/item/bio_chip)) // If it's not an implant.
				carried_item.add_mob_blood(target) // Oh yes, there will be blood...
		var/mob/living/carbon/human/H = target
		H.make_bloody_hands(H.get_blood_dna_list(), H.get_blood_color(), 0)
		H.bloody_body(target)
	return ITEM_INTERACT_COMPLETE

/obj/item/soap/deluxe
	desc = "A luxury bar of soap. Smells of honey."
	icon_state = "soapdeluxe"
	cleanspeed = 4 SECONDS // Slightly better because deluxe -- captain gets one of these.

/obj/item/soap/deluxe/laundry
	name = "laundry soap"
	desc = "Very cheap but effective soap. Dries out the skin."
	icon_state = "soapsoviet"

/obj/item/soap/syndie
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	icon_state = "soapsyndie"
	cleanspeed = 1 SECONDS // Much faster than mop so it is useful for traitors who want to clean crime scenes

/obj/item/soap/ds
	desc = "A very intimidating, jet-black bar of soap with a skull embossed on the top. Whatever this thing is made of, it can clean any mess in the blink of an eye."
	icon_state = "soapds"
	cleanspeed = 0.5 SECONDS

